# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe UpdateCookieCategory do
      subject { described_class.new(form) }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :admin, :confirmed, organization:) }
      let!(:cookie_management_config) { create(:awesome_config, organization:, var: :cookie_management, value: existing_categories) }
      let(:category_slug) { "awesome-analytics" }
      let(:form_params) do
        {
          slug: category_slug,
          title: { en: "Updated Analytics" },
          description: { en: "Updated description" },
          mandatory: true,
          visibility: "visible"
        }
      end
      let(:form) do
        CookieCategoryForm.from_params(form_params).with_context(
          current_organization: organization,
          current_user: user,
          categories:,
          id:
        )
      end
      let(:existing_categories) do
        {
          category_slug => {
            "slug" => category_slug,
            "title" => { "en" => "Awesome Analytics" },
            "description" => { "en" => "Old description" },
            "mandatory" => false,
            "visibility" => "visible",
            "items" => [{ "name" => "decidim_analytics_updated", "type" => "cookie", "service" => { "en" => "Updated Decidim" }, "expiration" => { "en" => "2 years" }, "description" => { "en" => "Updated tracking" } }]
          }
        }
      end
      let(:categories) { cookie_management_config.value }
      let(:id) { category_slug }

      describe "when valid" do
        it "broadcasts :ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "updates the category attributes" do
          subject.call
          category = cookie_management_config.reload.value[category_slug]
          expect(category["slug"]).to eq(category_slug)
          expect(category["title"]["en"]).to eq("Updated Analytics")
          expect(category["mandatory"]).to be(true)
          expect(category["visibility"]).to eq("visible")
        end

        it "preserves existing items" do
          subject.call
          category = cookie_management_config.reload.value[category_slug]
          expect(category["items"].count).to eq(1)
          expect(category["items"].first["name"]).to eq("decidim_analytics_updated")
        end

        context "when slug is changed" do
          let(:new_slug) { "updated-analytics" }
          let(:form_params) { super().merge(slug: new_slug) }

          it "updates the category under the new slug" do
            subject.call
            config = cookie_management_config.reload
            expect(config.value[new_slug]).not_to be_nil
            expect(config.value[new_slug]["title"]["en"]).to eq("Updated Analytics")
            expect(config.value[category_slug]).to be_nil
          end

          context "when new slug already exists" do
            let(:existing_categories) do
              {
                new_slug => {
                  "slug" => new_slug,
                  "title" => { "en" => "Existing Category" },
                  "description" => { "en" => "Existing description" },
                  "mandatory" => false,
                  "visibility" => "visible",
                  "items" => []
                },
                category_slug => {
                  "slug" => category_slug,
                  "title" => { "en" => "Awesome Analytics" },
                  "description" => { "en" => "Old description" },
                  "mandatory" => false,
                  "visibility" => "visible",
                  "items" => [{ "name" => "decidim_analytics_updated", "type" => "cookie", "service" => { "en" => "Updated Decidim" }, "expiration" => { "en" => "2 years" }, "description" => { "en" => "Updated tracking" } }]
                }
              }
            end

            it "broadcasts :invalid due to slug conflict" do
              expect { subject.call }.to broadcast(:invalid)
            end
          end
        end
      end

      describe "when invalid" do
        let(:form_params) { { slug: category_slug, title: { en: "" }, description: { en: "" }, visibility: "visible" } }

        it "broadcasts :invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end
    end
  end
end
