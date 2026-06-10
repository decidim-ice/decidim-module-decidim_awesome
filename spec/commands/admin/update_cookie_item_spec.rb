# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe UpdateCookieItem do
      subject { described_class.new(form, category_slug) }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :admin, :confirmed, organization:) }
      let!(:cookie_management_config) { create(:awesome_config, organization:, var: :cookie_management, value: existing_categories) }
      let(:category_slug) { "awesome-analytics" }
      let(:form_params) do
        {
          name: "decidim_analytics_updated",
          type: "cookie",
          service: { en: "Updated Decidim" },
          description: { en: "Updated tracking" },
          expiration: { en: "2 years" }
        }
      end
      let(:form) do
        CookieItemForm.from_params(form_params).with_context(
          current_organization: organization,
          current_user: user,
          id:,
          category:
        )
      end
      let(:id) { "decidim_analytics" }
      let(:category) { existing_categories[category_slug] }
      let(:existing_categories) do
        {
          "awesome-analytics" => {
            "slug" => "awesome-analytics",
            "title" => { "en" => "Awesome Analytics" },
            "description" => { "en" => "Old description" },
            "mandatory" => false,
            "visibility" => "visible",
            "items" => {
              id => {
                "name" => id,
                "type" => "cookie",
                "service" => { "en" => "Updated Decidim" },
                "expiration" => { "en" => "2 years" },
                "description" => { "en" => "Updated tracking" }
              }
            }
          },
          "another-category" => {
            "slug" => "another-category",
            "title" => { "en" => "Another Category" },
            "description" => { "en" => "Another description" },
            "mandatory" => false,
            "visibility" => "visible",
            "items" => {
              "decidim_analytics" => {
                "name" => "decidim_analytics",
                "type" => "cookie",
                "service" => { "en" => "Decidim" },
                "expiration" => { "en" => "1 year" },
                "description" => { "en" => "Tracking" }
              }
            }
          }
        }
      end

      it "broadcasts :ok" do
        expect { subject.call }.to broadcast(:ok)
        expect(cookie_management_config.reload.value[category_slug]["items"]["decidim_analytics_updated"]).to be_present
        expect(cookie_management_config.value[category_slug]["items"]["decidim_analytics"]).to be_nil
      end

      it "updates the item attributes" do
        subject.call
        item = cookie_management_config.reload.value[category_slug]["items"]["decidim_analytics_updated"]
        expect(item["name"]).to eq("decidim_analytics_updated")
        expect(item["service"]["en"]).to eq("Updated Decidim")
        expect(item["description"]["en"]).to eq("Updated tracking")
        expect(item["expiration"]["en"]).to eq("2 years")
      end

      describe "when invalid" do
        let(:form_params) { { name: "", type: "cookie" } }

        it "broadcasts :invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when category does not exist" do
        let(:category_slug) { "non-existent-category" }

        it "broadcasts :invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when category exists only as a decidim default (not in DB config)" do
        let(:category_slug) { "essential" }
        let(:category) { nil }

        before do
          allow(Decidim).to receive(:consent_categories).and_return([{ slug: :essential, mandatory: false, items: [] }])
        end

        it "broadcasts :ok and initializes the category in DB" do
          expect { subject.call }.to broadcast(:ok)
          expect(cookie_management_config.reload.value[category_slug]).to be_present
          expect(cookie_management_config.value[category_slug]["items"]["decidim_analytics_updated"]).to be_present
        end
      end

      context "when slug already exists" do
        let(:existing_categories) do
          {
            "awesome-analytics" => {
              "slug" => "awesome-analytics",
              "title" => { "en" => "Awesome Analytics" },
              "description" => { "en" => "Old description" },
              "mandatory" => false,
              "visibility" => "visible",
              "items" => {
                "decidim_analytics_updated" => {
                  "name" => "decidim_analytics_updated",
                  "type" => "cookie",
                  "service" => { "en" => "Updated Decidim" },
                  "expiration" => { "en" => "2 years" },
                  "description" => { "en" => "Updated tracking" }
                }
              }
            },
            "another-category" => {
              "slug" => "another-category",
              "title" => { "en" => "Another Category" },
              "description" => { "en" => "Another description" },
              "mandatory" => false,
              "visibility" => "visible",
              "items" => {}
            }
          }
        end

        it "broadcasts :invalid when item name already exists in the same category" do
          expect { subject.call }.to broadcast(:invalid)
        end

        context "when updating" do
          let(:id) { "decidim_analytics_updated" }

          it "allows updating the same item even if the name is the same" do
            expect { subject.call }.to broadcast(:ok)
          end
        end
      end
    end
  end
end
