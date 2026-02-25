# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe CreateCookieCategory do
      subject { described_class.new(form) }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :admin, :confirmed, organization: organization) }
      let(:form_params) do
        {
          slug: "awesome-analytics",
          title: { en: "Awesome Analytics" },
          description: { en: "Awesome analytics cookies" },
          mandatory: false
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
          config.value = { "categories" => [] }
        end
      end

      before do
        cookie_management_config
      end

      describe "when valid" do
        it "broadcasts :ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "creates a new category" do
          expect do
            subject.call
          end.to change { cookie_management_config.reload.value["categories"].count }.by(1)
        end

        it "stores the category with correct attributes" do
          subject.call
          category = cookie_management_config.reload.value["categories"].first

          expect(category["slug"]).to eq("awesome-analytics")
          expect(category["title"]["en"]).to eq("Awesome Analytics")
          expect(category["description"]["en"]).to eq("Awesome analytics cookies")
          expect(category["mandatory"]).to be(false)
          expect(category["items"]).to eq([])
        end
      end

      describe "when invalid" do
        context "when form is invalid" do
          let(:form_params) do
            {
              slug: "",
              title: { en: "Awesome Analytics" },
              description: { en: "Awesome analytics cookies" },
              mandatory: false
            }
          end

          it "broadcasts :invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          it "does not create a category" do
            expect do
              subject.call
            end.not_to(change { cookie_management_config.reload.value["categories"].count })
          end
        end

        context "when slug already exists" do
          before do
            cookie_management_config.value = {
              "categories" => [
                {
                  "slug" => "awesome-analytics",
                  "title" => { "en" => "Existing Awesome Analytics" },
                  "description" => { "en" => "Existing description" },
                  "mandatory" => false,
                  "items" => []
                }
              ]
            }
            cookie_management_config.save!
          end

          it "broadcasts :invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          it "does not create a duplicate category" do
            expect do
              subject.call
            end.not_to(change { cookie_management_config.reload.value["categories"].count })
          end

          it "adds error to form" do
            subject.call
            expect(form.errors[:slug]).to include("has already been taken")
          end
        end
      end
    end
  end
end
