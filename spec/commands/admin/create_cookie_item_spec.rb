# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe CreateCookieItem do
      subject { described_class.new(form, category_slug) }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :admin, :confirmed, organization: organization) }
      let(:category_slug) { "awesome-analytics" }
      let(:form_params) do
        {
          name: "google_awesome_analytics",
          type: "cookie",
          service: { en: "Google" },
          description: { en: "Awesome analytics tracking" }
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

      before do
        cookie_management_config
      end

      describe "when valid" do
        it "broadcasts :ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "creates a new item in the category" do
          expect do
            subject.call
          end.to change {
            cookie_management_config.reload.value["categories"].first["items"].count
          }.by(1)
        end

        it "stores the item with correct attributes" do
          subject.call
          category = cookie_management_config.reload.value["categories"].first
          item = category["items"].first

          expect(item["name"]).to eq("google_awesome_analytics")
          expect(item["type"]).to eq("cookie")
          expect(item["service"]["en"]).to eq("Google")
          expect(item["description"]["en"]).to eq("Awesome analytics tracking")
        end
      end

      describe "when invalid" do
        context "when form is invalid" do
          let(:form_params) do
            {
              name: "",
              type: "cookie",
              service: { en: "Google" },
              description: { en: "Awesome analytics tracking" }
            }
          end

          it "broadcasts :invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          it "does not create an item" do
            expect do
              subject.call
            end.not_to(change do
              cookie_management_config.reload.value["categories"].first["items"].count
            end)
          end
        end

        context "when category does not exist" do
          let(:category_slug) { "nonexistent" }

          it "broadcasts :invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          it "does not create an item" do
            initial_count = cookie_management_config.reload.value["categories"].first["items"].count
            subject.call
            final_count = cookie_management_config.reload.value["categories"].first["items"].count
            expect(final_count).to eq(initial_count)
          end
        end

        context "when item name already exists in category" do
          before do
            category = cookie_management_config.value["categories"].first
            category["items"] = [
              {
                "name" => "google_awesome_analytics",
                "type" => "cookie",
                "service" => { "en" => "Google" },
                "description" => { "en" => "Existing awesome analytics item" }
              }
            ]
            cookie_management_config.save!
          end

          it "broadcasts :invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          it "does not create a duplicate item" do
            expect do
              subject.call
            end.not_to(change do
              cookie_management_config.reload.value["categories"].first["items"].count
            end)
          end

          it "adds error to form" do
            subject.call
            expect(form.errors[:name]).to include("has already been taken")
          end
        end
      end
    end
  end
end
