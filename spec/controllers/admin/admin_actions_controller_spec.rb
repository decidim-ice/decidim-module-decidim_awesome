# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe AdminActionsController, type: :controller do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:user) { create(:user, :confirmed, :admin, organization: organization) }
      let(:organization) { create(:organization) }
      let(:allow_admin_accountability) { true }

      before do
        request.env["decidim.current_organization"] = user.organization
        sign_in user, scope: :user

        allow(Decidim::DecidimAwesome.config).to receive(:allow_admin_accountability).and_return(allow_admin_accountability)
      end

      describe "GET #index" do
        context "when admin accountability is enabled" do
          it "returns http success" do
            get :index, params: {}
            expect(response).to have_http_status(:success)
          end
        end

        context "when admin accountability is disabled" do
          let!(:allow_admin_accountability) { :disabled }

          it "returns http success" do
            get :index, params: {}
            expect(response).to have_http_status(:found)
          end
        end
      end
    end
  end
end
