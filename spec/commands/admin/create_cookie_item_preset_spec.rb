# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe CreateCookieItemPreset do
      subject { described_class.new(forms, category_slug) }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :admin, :confirmed, organization:) }
      let(:category_slug) { "awesome-analytics" }
      let(:form_params) do
        [
          { name: "YSC", type: "cookie", service: { en: "YouTube" }, description: { en: "YouTube session cookie" }, expiration: { en: "session" } },
          { name: "PREF", type: "cookie", service: { en: "YouTube" }, description: { en: "YouTube preferences" }, expiration: { en: "1 year" } }
        ]
      end
      let(:forms) do
        form_params.map do |params|
          CookieItemForm.from_params(params).with_context(
            current_organization: organization,
            current_user: user
          )
        end
      end
      let!(:cookie_management_config) { create(:awesome_config, organization:, var: :cookie_management, value: existing_categories) }
      let(:existing_categories) do
        {
          category_slug => {
            "slug" => category_slug,
            "title" => { "en" => "Awesome Analytics" },
            "description" => { "en" => "Awesome analytics cookies" },
            "mandatory" => false,
            "visibility" => "visible",
            "items" => {}
          }
        }
      end

      describe "when valid" do
        it "broadcasts :ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "creates all items in the category" do
          expect do
            subject.call
          end.to change {
            cookie_management_config.reload.value[category_slug]["items"].count
          }.by(2)
        end
      end

      describe "when invalid" do
        context "when the preset is added twice" do
          before { subject.call }

          it "broadcasts :invalid on the second call" do
            expect { subject.call }.to broadcast(:invalid)
          end

          it "does not create duplicate items" do
            expect do
              subject.call
            end.not_to(change do
              cookie_management_config.reload.value[category_slug]["items"].count
            end)
          end
        end

        context "when one form is invalid" do
          let(:form_params) do
            [
              { name: "", type: "cookie", service: { en: "YouTube" }, description: { en: "YouTube session cookie" }, expiration: { en: "session" } },
              { name: "PREF", type: "cookie", service: { en: "YouTube" }, description: { en: "YouTube preferences" }, expiration: { en: "1 year" } }
            ]
          end

          it "broadcasts :invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          it "does not create the invalid item" do
            subject.call
            count = cookie_management_config.reload.value[category_slug]["items"].count
            expect(count).to eq(1)
          end
        end
      end
    end
  end
end
