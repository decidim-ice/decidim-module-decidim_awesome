# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe CreateCookieItemPreset do
      subject { described_class.new(forms, category_slug) }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :admin, :confirmed, organization: organization) }
      let(:category_slug) { "awesome-analytics" }
      let(:form_params) do
        [
          { name: "YSC", type: "cookie", service: { en: "YouTube" }, description: { en: "YouTube session cookie" } },
          { name: "PREF", type: "cookie", service: { en: "YouTube" }, description: { en: "YouTube preferences" } }
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
      let(:cookie_management_config) do
        AwesomeConfig.find_or_create_by!(organization: organization, var: "cookie_management") do |config|
          config.value = {
            "categories" => [
              {
                "slug" => "awesome-analytics",
                "title" => { "en" => "Awesome Analytics" },
                "description" => { "en" => "Awesome analytics cookies" },
                "mandatory" => false,
                "visibility" => "default",
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

        it "creates all items in the category" do
          expect do
            subject.call
          end.to change {
            cookie_management_config.reload.value["categories"].first["items"].count
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
              cookie_management_config.reload.value["categories"].first["items"].count
            end)
          end
        end

        context "when one form is invalid" do
          let(:form_params) do
            [
              { name: "", type: "cookie", service: { en: "YouTube" }, description: { en: "YouTube session cookie" } },
              { name: "PREF", type: "cookie", service: { en: "YouTube" }, description: { en: "YouTube preferences" } }
            ]
          end

          it "broadcasts :invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          it "does not create the invalid item" do
            subject.call
            count = cookie_management_config.reload.value["categories"].first["items"].count
            expect(count).to eq(1)
          end
        end
      end
    end
  end
end
