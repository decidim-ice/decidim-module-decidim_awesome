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
          "items" => []
        }
      end

      let(:category_slug) { "awesome-category" }

      let(:cookie_management_config) do
        AwesomeConfig.find_or_create_by!(organization: organization, var: "cookie_management") do |config|
          config.value = { "categories" => [] }
        end
      end

      before do
        request.env["decidim.current_organization"] = user.organization
        sign_in user, scope: :user
        cookie_management_config
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
              slug: "new-category",
              title: { en: "New Awesome Category" },
              description: { en: "New Awesome description" },
              mandatory: false
            }
          }
        end

        context "when command succeeds" do
          it "redirects with success message" do
            post :create, params: params
            expect(flash[:notice]).not_to be_empty
            expect(response).to have_http_status(:redirect)
            expect(response).to redirect_to(decidim_admin_decidim_awesome.cookie_categories_path)
          end
        end

        context "when command fails" do
          before do
            cookie_management_config.value = { "categories" => [category_attributes] }
            cookie_management_config.save!
          end

          let(:params) do
            {
              cookie_category: {
                slug: category_slug,
                title: { en: "Duplicate" },
                description: { en: "Duplicate awesome description" },
                mandatory: false
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
        let(:params) { { slug: category_slug } }

        before do
          cookie_management_config.value = { "categories" => [category_attributes] }
          cookie_management_config.save!
        end

        it "returns http success" do
          get :edit, params: params
          expect(response).to have_http_status(:success)
        end

        context "when category does not exist" do
          let(:params) { { slug: "nonexistent" } }

          it "raises RecordNotFound" do
            expect { get :edit, params: params }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      describe "PATCH #update" do
        let(:params) do
          {
            slug: category_slug,
            cookie_category: {
              slug: category_slug,
              title: { en: "Updated Awesome Category" },
              description: { en: "Updated awesome description" },
              mandatory: true
            }
          }
        end

        before do
          cookie_management_config.value = { "categories" => [category_attributes] }
          cookie_management_config.save!
        end

        context "when command succeeds" do
          it "redirects with success message" do
            patch :update, params: params
            expect(flash[:notice]).not_to be_empty
            expect(response).to have_http_status(:redirect)
            expect(response).to redirect_to(decidim_admin_decidim_awesome.cookie_categories_path)
          end
        end

        context "when command fails" do
          let(:params) do
            {
              slug: "nonexistent",
              cookie_category: {
                slug: "nonexistent",
                title: { en: "Test" },
                description: { en: "Test" },
                mandatory: false
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
        let(:params) { { slug: category_slug } }

        before do
          cookie_management_config.value = { "categories" => [category_attributes] }
          cookie_management_config.save!
        end

        it "redirects with success message" do
          delete :destroy, params: params
          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(decidim_admin_decidim_awesome.cookie_categories_path)
        end
      end
    end
  end
end
