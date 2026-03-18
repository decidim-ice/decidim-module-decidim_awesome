# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe UpdateCookieItem do
      subject { described_class.new(form, category_slug) }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :admin, :confirmed, organization: organization) }
      let(:category_slug) { "awesome-analytics" }
      let(:form_params) do
        {
          name: "decidim_analytics_updated",
          editted: true,
          type: "cookie",
          service: { en: "Updated Decidim" },
          description: { en: "Updated tracking" },
          expiration: { en: "2 years" }
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
                "visibility" => "visible",
                "mandatory" => false,
                "editable" => true,
                "items" => [
                  { "name" => "decidim_analytics", "type" => "cookie", "service" => { "en" => "Decidim" }, "expiration" => { "en" => "1 year" }, "description" => { "en" => "Tracking for analytics" } }
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
          item = cookie_management_config.reload.value[category_slug]["items"][form.name]
          expect(item["name"]).to eq("decidim_analytics_updated")
          expect(item["service"]["en"]).to eq("Updated Decidim")
          expect(item["description"]["en"]).to eq("Updated tracking")
          expect(item["expiration"]["en"]).to eq("2 years")
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
