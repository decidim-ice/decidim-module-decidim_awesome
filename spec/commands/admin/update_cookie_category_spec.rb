# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe UpdateCookieCategory do
      subject { described_class.new(form) }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :admin, :confirmed, organization: organization) }
      let(:category_slug) { "awesome-analytics" }
      let(:form_params) do
        {
          slug: category_slug,
          title: { en: "Updated Analytics" },
          editable: true,
          description: { en: "Updated description" },
          mandatory: true,
          visibility: "visible"
        }
      end
      let(:form) do
        CookieCategoryForm.from_params(form_params).with_context(
          current_organization: organization,
          current_user: user
        )
      end
      let(:cookie_management_config) do
        AwesomeConfig.find_or_create_by!(organization: organization, var: "cookie_management") do |config|
          config.value = {
            category_slug => {
              "slug" => category_slug,
              "title" => { "en" => "Awesome Analytics" },
              "description" => { "en" => "Old description" },
              "mandatory" => false,
              "editable" => true,
              "visibility" => "visible",
              "items" => [{ "name" => "decidim_analytics_updated", "type" => "cookie", "service" => { "en" => "Updated Decidim" }, "expiration" => { "en" => "2 years" }, "description" => { "en" => "Updated tracking" } }]
            }
          }
        end
      end

      before { cookie_management_config }

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
