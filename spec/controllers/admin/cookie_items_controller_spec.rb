# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe CookieItemsController do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:user) { create(:user, :confirmed, :admin, organization:) }
      let(:organization) { create(:organization) }
      let(:category_data) do
        {
          "slug" => category_slug,
          "title" => { "en" => "My Awesome Category" },
          "description" => { "en" => "Awesome description" },
          "mandatory" => false,
          "items" => []
        }
      end

      let(:category_slug) { "test-category" }
      let(:item_name) { "test_cookie" }

      let(:item_attributes) do
        {
          "name" => item_name,
          "type" => "cookie",
          "service" => { "en" => "Awesome Service" },
          "description" => { "en" => "Awesome cookie description" }
        }
      end

      let(:cookie_management_config) do
        AwesomeConfig.find_or_create_by!(organization:, var: "cookie_management") do |config|
          config.value = { "categories" => [category_data] }
        end
      end

      let(:previous_value) { { "categories" => [category_data] } }

      before do
        request.env["decidim.current_organization"] = user.organization
        sign_in user, scope: :user
        cookie_management_config
      end

      describe "GET #index" do
        it "returns http success" do
          get :index, params: { cookie_category_slug: category_slug }
          expect(response).to have_http_status(:success)
        end
      end

      describe "GET #new" do
        it "returns http success" do
          get :new, params: { cookie_category_slug: category_slug }
          expect(response).to have_http_status(:success)
        end
      end

      describe "POST #create" do
        let(:params) do
          {
            cookie_category_slug: category_slug,
            cookie_item: {
              name: "new_cookie",
              type: "cookie",
              service: { en: "New Service" },
              description: { en: "New cookie description" }
            }
          }
        end
        let(:action) { post :create, params: }

        it "returns http success" do
          action
          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:redirect)
        end

        it "creates the new cookie item entry" do
          action

          config = AwesomeConfig.find_by(organization:, var: "cookie_management")
          category = config.value["categories"].find { |c| c["slug"] == category_slug }
          expect(category["items"]).to be_a(Array)
          expect(category["items"].count).to eq(1)
          expect(category["items"].first["name"]).to eq("new_cookie")
        end

        context "when duplicate item name" do
          before do
            cat = cookie_management_config.value["categories"].find { |c| c["slug"] == category_slug }
            cat["items"] = [{ "name" => "new_cookie" }]
            cookie_management_config.save!
          end

          it "returns error" do
            action
            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:ok)
          end
        end
      end

      describe "GET #edit" do
        let(:params) do
          {
            cookie_category_slug: category_slug,
            name: item_name
          }
        end

        before do
          cat = cookie_management_config.value["categories"].find { |c| c["slug"] == category_slug }
          cat["items"] = [item_attributes]
          cookie_management_config.save!
        end

        it "returns http success" do
          get :edit, params: params
          expect(response).to have_http_status(:success)
        end
      end

      describe "PATCH #update" do
        let(:params) do
          {
            cookie_category_slug: category_slug,
            name: item_name,
            cookie_item: {
              name: item_name,
              type: "cookie",
              service: { en: "Updated Service" },
              description: { en: "Updated description" }
            }
          }
        end

        before do
          cat = cookie_management_config.value["categories"].find { |c| c["slug"] == category_slug }
          cat["items"] = [item_attributes]
          cookie_management_config.save!
        end

        it "returns http success" do
          patch :update, params: params
          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:redirect)
        end

        it "updates the cookie item entry" do
          patch :update, params: params

          config = AwesomeConfig.find_by(organization:, var: "cookie_management")
          category = config.value["categories"].find { |c| c["slug"] == category_slug }
          item = category["items"].find { |i| i["name"] == item_name }
          expect(item["service"]["en"]).to eq("Updated Service")
        end
      end

      describe "DELETE #destroy" do
        let(:params) do
          {
            cookie_category_slug: category_slug,
            name: item_name
          }
        end

        before do
          cat = cookie_management_config.value["categories"].find { |c| c["slug"] == category_slug }
          cat["items"] = [item_attributes]
          cookie_management_config.save!
        end

        it "returns ok" do
          delete :destroy, params: params
          expect(flash[:notice]).not_to be_empty
        end

        it "destroys the item" do
          delete :destroy, params: params

          config = AwesomeConfig.find_by(organization:, var: "cookie_management")
          category = config.value["categories"].find { |c| c["slug"] == category_slug }
          expect(category["items"]).to eq([])
        end
      end
    end
  end
end
