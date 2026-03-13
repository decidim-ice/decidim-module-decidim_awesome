# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DecidimAwesome
    describe DataConsentCellOverride, type: :cell do
      subject { cell("decidim/data_consent", organization, context: { current_user: user }) }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization:) }
      let(:categories_data) do
        {
          "categories" => [
            {
              "slug" => "essential",
              "title" => { "en" => "Essential" },
              "description" => { "en" => "Essential cookies" },
              "mandatory" => true,
              "visibility" => "default",
              "items" => [
                {
                  "type" => "cookie",
                  "name" => "session_cookie",
                  "service" => { "en" => "Session" },
                  "description" => { "en" => "Session management" },
                  "expiration" => { "en" => "1 year" }
                }
              ]
            },
            {
              "slug" => "analytics",
              "title" => { "en" => "Analytics" },
              "description" => { "en" => "Analytics cookies" },
              "mandatory" => false,
              "visibility" => "default",
              "items" => []
            }
          ]
        }
      end

      describe "#categories" do
        context "when cookie_management is not configured" do
          it "returns the default Decidim categories" do
            default_slugs = Decidim.consent_categories.map { |c| c[:slug].to_s }
            expect(subject.categories.map { |c| c["slug"] }).to match_array(default_slugs)
          end

          it "returns categories with the expected keys" do
            category = subject.categories.first
            expect(category.keys).to include("slug", "mandatory", "title", "description", "visibility", "items")
          end
        end

        context "when cookie_management is configured" do
          before do
            create(:awesome_config, organization:, var: :cookie_management, value: categories_data)
          end

          it "returns the configured categories merged with defaults" do
            default_slugs = Decidim.consent_categories.map { |c| c[:slug].to_s }
            expect(subject.categories.map { |c| c["slug"] }).to match_array(default_slugs)
          end

          it "overrides default category attributes with custom values" do
            essential = subject.categories.find { |c| c["slug"] == "essential" }
            expect(essential["title"]).to eq("Essential")
            expect(essential["description"]).to eq("Essential cookies")
            expect(essential["mandatory"]).to be(true)
          end

          it "maps items from custom config" do
            essential = subject.categories.find { |c| c["slug"] == "essential" }
            item = essential["items"].find { |i| i["name"] == "session_cookie" }
            expect(item).to be_present
            expect(item["type"]).to eq("cookie")
            expect(item["service"]).to be_a(String)
          end

          it "returns empty items for categories without items" do
            analytics = subject.categories.find { |c| c["slug"] == "analytics" }
            expect(analytics["items"]).to be_empty
          end
        end
      end
    end
  end
end
