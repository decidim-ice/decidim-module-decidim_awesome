# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DecidimAwesome
    module Admin
      describe AwesomeAuthorizationPropertiesController do
        routes { Decidim::DecidimAwesome::AdminEngine.routes }

        let(:user) { create(:user, :confirmed, :admin, organization:) }
        let(:organization) { create(:organization, available_authorizations: ["awesome_authorization_handler"]) }

        before do
          request.env["decidim.current_organization"] = user.organization
          sign_in user, scope: :user
        end

        describe "GET #index" do
          context "when awesome_authorization_handler is enabled" do
            before do
              allow(Decidim::DecidimAwesome.config).to receive(:awesome_authorization_handler).and_return(true)
            end

            it "returns http success" do
              get(:index)
              expect(response).to have_http_status(:success)
            end

            it "renders the index template" do
              get(:index)
              expect(subject).to render_template(:index)
            end
          end

          context "when user is not admin" do
            let(:user) { create(:user, :confirmed, organization:) }

            it "redirects" do
              get(:index)
              expect(response).to have_http_status(:found)
            end
          end
        end
      end
    end
  end
end
