# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe CookieItemsController do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:user) { create(:user, :confirmed, :admin, organization:) }
      let(:organization) { create(:organization) }
      let!(:cookie_management_config) { create(:awesome_config, organization:, var: :cookie_management, value: existing_categories) }
      let(:category_data) do
        {
          "slug" => category_slug,
          "title" => { "en" => "My Awesome Category" },
          "description" => { "en" => "Awesome description" },
          "mandatory" => false,
          "visibility" => "visible",
          "items" => {}
        }
      end
      let(:existing_categories) do
        { category_slug => category_data }
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

      before do
        request.env["decidim.current_organization"] = user.organization
        sign_in user, scope: :user
      end

      describe "GET #index" do
        it "returns http success" do
          get :index, params: { cookie_category_id: category_slug }
          expect(response).to have_http_status(:success)
        end
      end

      describe "GET #new" do
        it "returns http success" do
          get :new, params: { cookie_category_id: category_slug }
          expect(response).to have_http_status(:success)
        end
      end

      describe "POST #create" do
        let(:params) do
          {
            cookie_category_id: category_slug,
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
            cookie_category_id: category_slug,
            id: item_name
          }
        end
        let(:category_data) do
          {
            "slug" => category_slug,
            "title" => { "en" => "My Awesome Category" },
            "description" => { "en" => "Awesome description" },
            "mandatory" => false,
            "visibility" => "visible",
            "items" => { item_name => item_attributes }
          }
        end

        it "returns http success" do
          get :edit, params: params
          expect(response).to have_http_status(:success)
        end
      end

      describe "PATCH #update" do
        let(:params) do
          {
            cookie_category_id: category_slug,
            id: item_name,
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
        let(:category_data) do
          {
            "slug" => category_slug,
            "title" => { "en" => "My Awesome Category" },
            "description" => { "en" => "Awesome description" },
            "mandatory" => false,
            "visibility" => "visible",
            "items" => { item_name => item_attributes }
          }
        end

        it "redirects with success message" do
          patch :update, params: params
          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(cookie_category_cookie_items_path(category_slug))
        end

        context "when the item is blocked" do
          let(:category_slug) { "essential" }
          let(:item_name) { "_session_id" }

          context "when attempting to change a protected field (type)" do
            let(:params_with_mandatory_false) do
              params.deep_merge(cookie_item: { type: "local_storage" })
            end

            it "renders edit with an error when blocked flag is submitted" do
              patch :update, params: params_with_mandatory_false
              expect(flash[:alert]).not_to be_empty
              expect(response).to render_template(:edit)
            end
          end
        end
      end

      describe "DELETE #destroy" do
        let(:params) do
          {
            cookie_category_id: category_slug,
            id: item_name
          }
        end
        let(:category_data) do
          {
            "slug" => category_slug,
            "title" => { "en" => "My Awesome Category" },
            "description" => { "en" => "Awesome description" },
            "mandatory" => false,
            "visibility" => "visible",
            "items" => { item_name => item_attributes }
          }
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
