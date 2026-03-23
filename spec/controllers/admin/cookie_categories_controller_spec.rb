# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe CookieCategoriesController do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:user) { create(:user, :confirmed, :admin, organization:) }
      let(:organization) { create(:organization) }
      let(:category_attributes) do
        {
          "slug" => category_slug,
          "title" => { "en" => "Awesome Category" },
          "description" => { "en" => "Awesome description" },
          "mandatory" => false,
          "visibility" => "visible",
          "items" => {}
        }
      end

      let(:category_slug) { "awesome-category" }
      let!(:cookie_management_config) { create(:awesome_config, organization:, var: :cookie_management, value: existing_categories) }
      let(:existing_categories) do
        {
          category_slug => category_attributes
        }
      end

      before do
        request.env["decidim.current_organization"] = user.organization
        sign_in user, scope: :user
      end

      describe "GET #index" do
        it "returns http success" do
          get :index
          expect(response).to have_http_status(:success)
        end
      end

      describe "GET #new" do
        it "returns http success" do
          get :new
          expect(response).to have_http_status(:success)
        end
      end

      describe "POST #create" do
        let(:params) do
          {
            cookie_category: {
              slug: "new-awesome-category",
              title: { en: "New Awesome Category" },
              description: { en: "New Awesome description" },
              mandatory: false,
              visibility: "visible"
            }
          }
        end

        context "when command succeeds" do
          it "redirects with success message" do
            post :create, params: params
            expect(flash[:notice]).not_to be_empty
            expect(response).to have_http_status(:redirect)
            expect(response).to redirect_to(cookie_categories_path)
          end
        end

        context "when command fails" do
          let(:params) do
            {
              cookie_category: {
                slug: "new-awesome-category",
                title: { en: "" },
                description: { en: "Description without title" },
                mandatory: false,
                visibility: "visible"
              }
            }
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
        let(:params) { { id: category_slug } }

        it "returns http success" do
          get :edit, params: params
          expect(response).to have_http_status(:success)
        end
      end

      describe "PATCH #update" do
        let(:params) do
          {
            id: category_slug,
            cookie_category: {
              slug: category_slug,
              title: { en: "Updated Awesome Category" },
              description: { en: "Updated awesome description" },
              mandatory: true,
              visibility: "visible"
            }
          }
        end

        context "when command succeeds" do
          it "redirects with success message" do
            patch :update, params: params
            expect(flash[:notice]).not_to be_empty
            expect(response).to have_http_status(:redirect)
            expect(response).to redirect_to(cookie_categories_path)
          end
        end

        context "when the category is blocked" do
          let(:category_slug) { "essential" }
          let(:category_attributes) do
            {
              "slug" => category_slug,
              "title" => { "en" => "Awesome Category" },
              "description" => { "en" => "Awesome description" },
              "mandatory" => false,
              "visibility" => "visible",
              "items" => {}
            }
          end

          context "when attempting to change a protected field (mandatory)" do
            let(:params_with_mandatory_false) do
              params.deep_merge(cookie_category: { mandatory: false })
            end

            it "renders edit with an error when blocked flag is submitted" do
              patch :update, params: params_with_mandatory_false
              expect(response).to render_template(:edit)
            end
          end
        end

        context "when command fails" do
          let(:params) do
            {
              id: category_slug,
              cookie_category: {
                slug: category_slug,
                title: { en: "" },
                description: { en: "Test" },
                mandatory: false,
                visibility: "visible"
              }
            }
          end

          it "renders edit with error message" do
            patch :update, params: params
            expect(response).to have_http_status(:success)
            expect(response).to render_template(:edit)
            expect(flash[:alert]).to be_present
          end
        end
      end

      describe "DELETE #destroy" do
        let(:params) { { id: category_slug } }

        it "redirects with success message" do
          delete :destroy, params: params
          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(cookie_categories_path)
        end
      end
    end
  end
end
