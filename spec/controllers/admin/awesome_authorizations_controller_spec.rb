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

      describe "GET #new" do
        it "returns http success" do
          get :new
          expect(response).to have_http_status(:success)
        end

        it "renders the new template" do
          get :new
          expect(subject).to render_template(:new)
        end
      end

      describe "POST #create" do
        let(:params) do
          {
            awesome_authorization_group: {
              name: { en: "New Group" },
              purpose: { en: "New Group Purpose" }
            }
          }
        end

        context "when command succeeds" do
          it "redirects with a success notice" do
            post :create, params: params
            expect(flash[:notice]).not_to be_empty
            expect(response).to have_http_status(:redirect)
            expect(response).to redirect_to(awesome_authorizations_path)
          end

          it "creates the authorization group" do
            expect { post :create, params: params }.to change(Decidim::DecidimAwesome::AuthorizationGroup, :count).by(1)
          end
        end

        context "when command fails" do
          let(:params) do
            {
              awesome_authorization_group: {
                name: { en: "" },
                purpose: { en: "New Group Purpose" }
              }
            }
          end

          it "renders new with an alert" do
            post :create, params: params
            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:ok)
            expect(response).to render_template(:new)
          end

          it "does not create the authorization group" do
            expect { post :create, params: params }.not_to change(Decidim::DecidimAwesome::AuthorizationGroup, :count)
          end
        end
      end

      describe "GET #edit" do
        let!(:authorization_group) { create(:awesome_authorization_group, organization:) }

        it "returns http success" do
          get :edit, params: { id: authorization_group.id }
          expect(response).to have_http_status(:success)
        end

        it "renders the edit template" do
          get :edit, params: { id: authorization_group.id }
          expect(subject).to render_template(:edit)
        end
      end

      describe "PATCH #update" do
        let!(:authorization_group) { create(:awesome_authorization_group, organization:) }
        let(:params) do
          {
            id: authorization_group.id,
            awesome_authorization_group: {
              name: { en: "Updated Group Name" },
              purpose: { en: "Updated Group Purpose" }
            }
          }
        end

        context "when command succeeds" do
          it "redirects with a success notice" do
            patch :update, params: params
            expect(flash[:notice]).not_to be_empty
            expect(response).to have_http_status(:redirect)
            expect(response).to redirect_to(awesome_authorizations_path)
          end

          it "updates the authorization group" do
            patch :update, params: params
            expect(authorization_group.reload.name["en"]).to eq("Updated Group Name")
          end
        end

        context "when command fails" do
          let(:params) do
            {
              id: authorization_group.id,
              awesome_authorization_group: {
                name: { en: "" },
                purpose: { en: "Updated Group Purpose" }
              }
            }
          end

          it "renders edit with an alert" do
            patch :update, params: params
            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:ok)
            expect(response).to render_template(:edit)
          end
        end
      end

      describe "POST #sync" do
        let!(:authorization_group) { create(:awesome_authorization_group, organization:) }

        it "enqueues the synchronization job and redirects" do
          expect(Decidim::DecidimAwesome::SyncAwesomeAuthorizationGroupJob).to receive(:perform_later).with(authorization_group.id)

          post :sync, params: { id: authorization_group.id }

          expect(response).to have_http_status(:redirect)
          expect(flash[:notice]).to be_present
        end
      end

      describe "DELETE #destroy" do
        let!(:authorization_group) { create(:awesome_authorization_group, organization:) }

        it "redirects with a success notice" do
          delete :destroy, params: { id: authorization_group.id }
          expect(flash[:notice]).not_to be_empty
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(awesome_authorizations_path)
        end

        it "destroys the authorization group" do
          expect { delete :destroy, params: { id: authorization_group.id } }.to change(Decidim::DecidimAwesome::AuthorizationGroup, :count).by(-1)
        end

        it "revokes authorizations for users tied to the group" do
          user = create(:user, :confirmed, organization:, email: "member@example.org")
          create(:awesome_authorization_member, authorization_group:, email: user.email)
          create(
            :authorization,
            :granted,
            user:,
            name: "awesome_authorization_handler",
            metadata: { "groups" => { authorization_group.id.to_s => authorization_group.name } }
          )

          expect do
            delete :destroy, params: { id: authorization_group.id }
            perform_enqueued_jobs
          end.to change { Decidim::Authorization.where(user: user, name: "awesome_authorization_handler").count }.from(1).to(0)
        end
      end
    end
  end
end
