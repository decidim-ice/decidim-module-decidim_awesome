# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DecidimAwesome
    describe DataConsentCell, type: :cell do
      subject { cell("decidim/decidim_awesome/data_consent", organization, context: { current_user: user }).call }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization:) }
      let(:config) { create(:awesome_config, organization:, var: :cookie_management) }
      let(:categories_data) do
        {
          "categories" => [
            {
              "slug" => "essential",
              "title" => { "en" => "Essential" },
              "description" => { "en" => "Essential cookies" },
              "mandatory" => true,
              "visibility" => "all",
              "items" => [
                {
                  "type" => "cookie",
                  "name" => "session_cookie",
                  "service" => { "en" => "Session" },
                  "description" => { "en" => "Session management" }
                }
              ]
            },
            {
              "slug" => "analytics",
              "title" => { "en" => "Analytics" },
              "description" => { "en" => "Analytics cookies" },
              "mandatory" => false,
              "visibility" => "all",
              "items" => []
            }
          ]
        }
      end

      context "when cookie_management is not configured" do
        it "renders the default Decidim categories" do
          expect(subject).to have_css("#dc-modal")
          expect(subject).to have_css(".cookies__category")
        end
      end

      context "when cookie_management is configured" do
        before do
          config.update!(value: categories_data)
        end

        it "renders the modal" do
          expect(subject).to have_css("#dc-modal")
        end

        it "renders custom categories" do
          expect(subject).to have_css(".cookies__category[data-id='essential']")
          expect(subject).to have_css(".cookies__category[data-id='analytics']")
        end

        it "renders category titles" do
          expect(subject).to have_content("Essential")
          expect(subject).to have_content("Analytics")
        end

        it "renders category descriptions" do
          expect(subject).to have_content("Essential cookies")
          expect(subject).to have_content("Analytics cookies")
        end

        it "marks mandatory categories as checked and disabled" do
          expect(subject).to have_css("input[name='essential'][checked='checked'][disabled]")
        end

        it "renders optional categories as enabled" do
          expect(subject).to have_css("input[name='analytics']:not([disabled])")
        end

        context "when category has items" do
          it "renders cookie items" do
            expect(subject).to have_content("session_cookie")
            expect(subject).to have_content("Session")
            expect(subject).to have_content("Session management")
          end

          it "renders item type" do
            expect(subject).to have_content(I18n.t("layouts.decidim.data_consent.details.types.cookie"))
          end
        end
      end
    end
  end
end
