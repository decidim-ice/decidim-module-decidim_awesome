# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe AwesomeAuthorizationsController do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:user) { create(:user, :confirmed, :admin, organization:) }
      let(:organization) { create(:organization, available_authorizations: available_authorizations) }
      let(:available_authorizations) { ["awesome_authorization_handler"] }

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

          context "when authorization is available in organization" do
            it "shows available as true" do
              get(:index)
              expect(controller.send(:available?)).to be true
            end
          end

          context "when authorization is not available in organization" do
            let(:available_authorizations) { [] }

            it "shows available as false" do
              get(:index)
              expect(controller.send(:available?)).to be false
            end
          end
        end

        context "when awesome_authorization_handler is disabled" do
          before do
            allow(Decidim::DecidimAwesome.config).to receive(:awesome_authorization_handler).and_return(false)
          end

          it "returns http success (permission check happens at authorization level)" do
            get(:index)
            expect(response).to have_http_status(:success)
          end
        end

        context "when awesome_authorization_handler is set to :disabled" do
          before do
            allow(Decidim::DecidimAwesome.config).to receive(:awesome_authorization_handler).and_return(:disabled)
          end

          it "redirects" do
            get(:index)
            expect(response).to have_http_status(:found)
          end
        end
      end
    end
  end
end
