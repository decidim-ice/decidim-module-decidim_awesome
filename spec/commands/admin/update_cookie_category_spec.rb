# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe UpdateCookieCategory do
      subject { described_class.new(form, category_slug) }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :admin, :confirmed, organization: organization) }
      let(:category_slug) { "awesome-analytics" }
      let(:form_params) do
        {
          slug: "awesome-analytics",
          title: { en: "Updated Analytics" },
          description: { en: "Updated description" },
          mandatory: true,
          visibility: "default"
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
            "categories" => [
              {
                "slug" => "awesome-analytics",
                "title" => { "en" => "Awesome Analytics" },
                "description" => { "en" => "Old description" },
                "mandatory" => false,
                "visibility" => "default",
                "items" => [{ "name" => "Decidim Analytics", "type" => "cookie" }]
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

        it "updates the category attributes" do
          subject.call
          category = cookie_management_config.reload.value["categories"].first
          expect(category["slug"]).to eq("awesome-analytics")
          expect(category["title"]["en"]).to eq("Updated Analytics")
          expect(category["mandatory"]).to be(true)
          expect(category["visibility"]).to eq("default")
        end

        it "preserves existing items" do
          subject.call
          category = cookie_management_config.reload.value["categories"].first
          expect(category["items"].count).to eq(1)
          expect(category["items"].first["name"]).to eq("Decidim Analytics")
        end
      end

      describe "when invalid" do
        let(:form_params) { { slug: "awesome-analytics", title: { en: "" }, description: { en: "" }, visibility: "default" } }

        it "broadcasts :invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end
    end
  end
end
