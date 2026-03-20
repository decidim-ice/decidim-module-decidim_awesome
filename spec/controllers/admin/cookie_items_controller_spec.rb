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
          "editable" => true,
          "description" => { "en" => "Awesome description" },
          "mandatory" => false,
          "visibility" => "default",
          "items" => {}
        }
      end

      let(:category_slug) { "test-category" }
      let(:item_name) { "test_cookie" }

      let(:item_attributes) do
        {
          "name" => item_name,
          "type" => "cookie",
          "edited" => true,
          "service" => { "en" => "Awesome Service" },
          "description" => { "en" => "Awesome cookie description" },
          "expiration" => { "en" => "1 year" }
        }
      end

      let(:cookie_management_config) do
        AwesomeConfig.find_or_create_by!(organization:, var: "cookie_management") do |config|
          config.value = { category_slug => category_data }
        end
      end

      let(:previous_value) { { category_slug => category_data } }

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
              edited: true,
              service: { en: "New Service" },
              description: { en: "New cookie description" },
              expiration: { en: "6 months" }
            }
          }
        end

        context "when command succeeds" do
          it "redirects with success message" do
            post :create, params: params
            expect(flash[:notice]).not_to be_empty
            expect(response).to have_http_status(:redirect)
            expect(response).to redirect_to(cookie_category_cookie_items_path(category_slug))
          end
        end

        context "when command fails" do
          before do
            cat = cookie_management_config.value[category_slug]
            cat["items"] = { "new_cookie" => { "name" => "new_cookie" } }
            cookie_management_config.save!
          end

          it "renders new with error message" do
            post :create, params: params
            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:ok)
            expect(response).to render_template(:new)
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
          cookie_management_config.value = {
            category_slug => category_data.merge("items" => { item_name => item_attributes })
          }
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
              edited: true,
              service: { en: "Updated Service" },
              description: { en: "Updated description" },
              expiration: { en: "1 year" }
            }
          }
        end

        before do
          cookie_management_config.value = {
            category_slug => category_data.merge("items" => { item_name => item_attributes })
          }
          cookie_management_config.save!
        end

        it "redirects with success message" do
          patch :update, params: params
          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(cookie_category_cookie_items_path(category_slug))
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
          cookie_management_config.value = {
            category_slug => category_data.merge("items" => { item_name => item_attributes })
          }
          cookie_management_config.save!
        end

        it "redirects with success message" do
          delete :destroy, params: params
          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(cookie_category_cookie_items_path(category_slug))
        end
      end
    end
  end
end
