# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe EditorsController, type: :controller do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:user) { create(:user, :confirmed, :admin, organization: organization) }
      let(:organization) { create(:organization) }
      let(:config) do
        {
          allow_images_in_full_editor: false,
          allow_images_in_small_editor: false
        }
      end
      let(:params) do
        {
          allow_images_in_full_editor: true,
          allow_images_in_small_editor: true
        }
      end

      before do
        request.env["decidim.current_organization"] = user.organization
        sign_in user, scope: :user
      end

      describe "GET #show" do
        it "returns http success" do
          get :show
          expect(response).to have_http_status(:success)
        end
      end

      describe "PATCH #update" do
        it "redirects as success success" do
          get :update, params: params
          expect(response).to have_http_status(:redirect)
        end
      end
    end
  end
end
