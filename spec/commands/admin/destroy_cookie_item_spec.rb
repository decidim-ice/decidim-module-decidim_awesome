# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe DestroyCookieItem do
      subject { described_class.new(category_slug, item_name, organization) }

      let(:organization) { create(:organization) }
      let(:category_slug) { "awesome-analytics" }
      let(:item_name) { "Decidim Awesome Analytics" }
      let(:cookie_management_config) do
        AwesomeConfig.find_or_create_by!(organization: organization, var: "cookie_management") do |config|
          config.value = {
            category_slug => {
              "slug" => category_slug,
              "title" => { "en" => "Awesome Analytics" },
              "edited" => true,
              "description" => { "en" => "Awesome analytics cookies" },
              "mandatory" => false,
              "visibility" => "default",
              "items" => {
                "Decidim Awesome Analytics" => { "name" => "Decidim Awesome Analytics", "type" => "cookie" },
                "Awesome Facebook Analytics" => { "name" => "Awesome Facebook Analytics", "type" => "cookie" }
              }
            }
          }
        end
      end

      before { cookie_management_config }

      describe "when valid" do
        it "broadcasts :ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "removes the item from category" do
          expect do
            subject.call
          end.to change { cookie_management_config.reload.value[category_slug]["items"].keys.count }.by(-1)
        end

        it "removes only the specified item" do
          subject.call
          items = cookie_management_config.reload.value[category_slug]["items"]
          expect(items).not_to have_key("Decidim Awesome Analytics")
          expect(items).to have_key("Awesome Facebook Analytics")
        end
      end
    end
  end
end
