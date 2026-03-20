# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe DestroyCookieCategory do
      subject { described_class.new(category_slug, organization) }

      let(:organization) { create(:organization) }
      let(:category_slug) { "awesome-analytics" }
      let(:cookie_management_config) do
        AwesomeConfig.find_or_create_by!(organization: organization, var: "cookie_management") do |config|
          config.value = {
            "awesome-analytics" => {
              "slug" => "awesome-analytics",
              "title" => { "en" => "Awesome Analytics" },
              "edited" => true,
              "description" => { "en" => "Awesome analytics cookies" },
              "mandatory" => false,
              "visibility" => "default",
              "items" => {}
            },
            "marketing" => {
              "slug" => "marketing",
              "title" => { "en" => "Marketing" },
              "edited" => true,
              "description" => { "en" => "Marketing cookies" },
              "mandatory" => false,
              "visibility" => "default",
              "items" => {}
            }
          }
        end
      end

      before { cookie_management_config }

      describe "when valid" do
        it "broadcasts :ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "removes the category" do
          expect do
            subject.call
          end.to change { cookie_management_config.reload.value.keys.count }.by(-1)
        end

        it "removes the category and its items" do
          subject.call
          categories = cookie_management_config.reload.value
          expect(categories).not_to have_key("awesome-analytics")
          expect(categories).to have_key("marketing")
        end
      end
    end
  end
end
