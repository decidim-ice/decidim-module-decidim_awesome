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
            "categories" => [
              {
                "slug" => "awesome-analytics",
                "title" => { "en" => "Awesome Analytics" },
                "description" => { "en" => "Awesome analytics cookies" },
                "mandatory" => false,
                "items" => [{ "name" => "Google Analytics", "type" => "cookie" }]
              },
              {
                "slug" => "marketing",
                "title" => { "en" => "Marketing" },
                "description" => { "en" => "Marketing cookies" },
                "mandatory" => false,
                "items" => []
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

        it "removes the category" do
          expect do
            subject.call
          end.to change { cookie_management_config.reload.value["categories"].count }.by(-1)
        end

        it "removes the category and its items" do
          subject.call
          categories = cookie_management_config.reload.value["categories"]
          expect(categories.any? { |c| c["slug"] == "awesome-analytics" }).to be(false)
          expect(categories.any? { |c| c["slug"] == "marketing" }).to be(true)
        end
      end
    end
  end
end
