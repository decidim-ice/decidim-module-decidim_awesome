# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe AwesomeAuthorizationUsersController do
      include ActiveJob::TestHelper

      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:organization) { create(:organization, available_authorizations: ["awesome_authorization_handler"]) }
      let(:user) { create(:user, :confirmed, :admin, organization:) }
      let!(:authorization_group) { create(:awesome_authorization_group, organization:) }

      before do
        request.env["decidim.current_organization"] = user.organization
        sign_in user, scope: :user
        clear_enqueued_jobs
      end

      describe "GET #index" do
        it "returns http success" do
          get :index, params: { awesome_authorization_id: authorization_group.id }
          expect(response).to have_http_status(:success)
        end
      end

      describe "POST #create" do
        let(:base_params) { { awesome_authorization_id: authorization_group.id } }

        context "when using manual emails" do
          let(:params) do
            base_params.merge(emails: "alice@example.org\n bob@example.org")
          end

          it "creates members" do
            expect { post :create, params: params }.to change(Decidim::DecidimAwesome::AuthorizationMember, :count).by(2)
          end

          it "redirects with notice" do
            post :create, params: params
            expect(response).to have_http_status(:redirect)
            expect(flash[:notice]).to be_present
          end

          it "enqueues a synchronization job" do
            expect(Decidim::DecidimAwesome::SyncAwesomeAuthorizationGroupJob).to receive(:perform_later).with(authorization_group.id)
            post :create, params: params
          end
        end

        context "when using csv file" do
          let(:csv_blob) do
            csv_path = File.expand_path("../../fixtures/files/authorization_members.csv", __dir__)

            ActiveStorage::Blob.create_and_upload!(
              io: StringIO.new(File.read(csv_path)),
              filename: "authorization_members.csv",
              content_type: "text/csv"
            )
          end
          let(:params) do
            base_params.merge(file: csv_blob.signed_id)
          end

          it "creates members from csv" do
            expect { post :create, params: params }.to change(Decidim::DecidimAwesome::AuthorizationMember, :count).by(2)
          end
        end

        context "when no valid input is provided" do
          let(:params) { base_params.merge(emails: "") }

          it "renders new with alert" do
            post :create, params: params
            expect(response).to have_http_status(:ok)
            expect(response).to render_template(:new)
            expect(flash[:alert]).to be_present
          end
        end
      end

      describe "DELETE #destroy" do
        let!(:member) { create(:awesome_authorization_member, authorization_group:, email: "member@example.org") }

        it "removes the member" do
          expect do
            delete :destroy, params: { awesome_authorization_id: authorization_group.id, id: member.id }
          end.to change(Decidim::DecidimAwesome::AuthorizationMember, :count).by(-1)
        end

        it "redirects with notice" do
          delete :destroy, params: { awesome_authorization_id: authorization_group.id, id: member.id }
          expect(response).to have_http_status(:redirect)
          expect(flash[:notice]).to be_present
        end

        it "enqueues a synchronization job" do
          expect(Decidim::DecidimAwesome::SyncAwesomeAuthorizationGroupJob).to receive(:perform_later).with(authorization_group.id)
          delete :destroy, params: { awesome_authorization_id: authorization_group.id, id: member.id }
        end
      end
    end
  end
end
