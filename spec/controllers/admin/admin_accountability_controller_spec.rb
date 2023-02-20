# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe AdminAccountabilityController, type: :controller do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:user) { create(:user, :confirmed, :admin, organization: organization) }
      let(:organization) { create(:organization) }
      let(:admin_accountability) { [:participatory_space_roles, :admin_roles] }

      before do
        request.env["decidim.current_organization"] = user.organization
        sign_in user, scope: :user

        allow(Decidim::DecidimAwesome.config).to receive(:admin_accountability).and_return(admin_accountability)
      end

      describe "GET #index" do
        context "when admin accountability is enabled" do
          it "returns http success" do
            get :index, params: {}
            expect(response).to have_http_status(:success)
          end

          it "returns http success for globa admins" do
            get :index, params: { admins: true }
            expect(response).to have_http_status(:success)
          end
        end

        context "when admin accountability is disabled" do
          let!(:admin_accountability) { :disabled }

          it "returns http redirect" do
            get :index, params: {}
            expect(response).to have_http_status(:redirect)
          end

          it "returns http redirect for globa admins" do
            get :index, params: { admins: true }
            expect(response).to have_http_status(:redirect)
          end
        end

        context "when admin accountability is for spaces only" do
          let!(:admin_accountability) { [:participatory_space_roles] }

          it "returns http success" do
            get :index, params: {}
            expect(response).to have_http_status(:success)
          end

          it "returns http success for globa admins" do
            get :index, params: { admins: true }
            expect(response).to have_http_status(:redirect)
          end
        end

        context "when admin accountability is for admins only" do
          let!(:admin_accountability) { [:admin_roles] }

          it "returns http success" do
            get :index, params: {}
            expect(response).to have_http_status(:redirect)
          end

          it "returns http success for globa admins" do
            get :index, params: { admins: true }
            expect(response).to have_http_status(:success)
          end
        end
      end
    end
  end
end
