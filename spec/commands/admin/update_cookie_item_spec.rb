# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe UpdateCookieItem do
      subject { described_class.new(form, category_slug, item_name) }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :admin, :confirmed, organization: organization) }
      let(:category_slug) { "awesome-analytics" }
      let(:item_name) { "decidim_analytics" }
      let(:form_params) do
        {
          name: "decidim_analytics_updated",
          type: "cookie",
          service: { en: "Updated Decidim" },
          description: { en: "Updated tracking" }
        }
      end
      let(:form) do
        CookieItemForm.from_params(form_params).with_context(
          current_organization: organization,
          current_user: user
        )
      end
      let(:cookie_management_config) do
        AwesomeConfig.find_or_create_by!(organization: organization, var: "cookie_management") do |config|
          config.value = {
            "categories" => [
              {
                "slug" => "awesome-analytics",
                "title" => { "en" => "Analytics" },
                "visibility" => "default",
                "items" => [
                  { "name" => "decidim_analytics", "type" => "cookie", "service" => { "en" => "Decidim" } }
                ]
              }
            ]
          }
        end
      end

      before { cookie_management_config }

      describe "when valid" do
        it "broadcasts :ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "updates the item attributes" do
          subject.call
          item = cookie_management_config.reload.value["categories"].first["items"].first
          expect(item["name"]).to eq("decidim_analytics_updated")
          expect(item["service"]["en"]).to eq("Updated Decidim")
        end
      end

      describe "when invalid" do
        let(:form_params) { { name: "", type: "cookie" } }

        it "broadcasts :invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end
    end
  end
end
