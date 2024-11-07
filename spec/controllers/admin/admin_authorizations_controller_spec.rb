# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe AdminAuthorizationsController do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:user) { create(:user, :confirmed, :admin, organization: organization) }
      let(:organization) { create(:organization, available_authorizations: [handler]) }
      let!(:awesome_config) { create(:awesome_config, organization: organization, var: :admins_available_authorizations, value: [awesome_handler]) }
      let(:params) { { id: user.id, handler: handler } }
      let(:handler) { "dummy_authorization_handler" }
      let(:awesome_handler) { "dummy_authorization_handler" }
      let(:admins_available_authorizations) { [] }
      let(:body) { response.parsed_body }

      before do
        request.env["decidim.current_organization"] = user.organization
        sign_in user, scope: :user

        allow(Decidim::DecidimAwesome.config).to receive(:admins_available_authorizations).and_return(admins_available_authorizations)
      end

      describe "GET #edit" do
        it "renders edit template" do
          get(:edit, params: params)
          expect(response).to have_http_status(:success)
          expect(subject).to render_template(:edit)
        end

        context "when authorization exists" do
          let!(:authorization) { create(:authorization, user: user, name: handler) }

          it "renders authorization template" do
            get(:edit, params: params)
            expect(response).to have_http_status(:success)
            expect(subject).to render_template(:authorization)
          end
        end

        context "when authorization is not allowed" do
          let(:awesome_handler) { "another_dummy_authorization_handler" }

          it "returns http redirect" do
            get(:edit, params: params)
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context "when disabled" do
          let(:admins_available_authorizations) { :disabled }

          it "returns http redirect" do
            get(:edit, params: params)
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      describe "PATCH #update" do
        let(:params) do
          {
            id: user.id,
            handler: handler,
            force_verification: force_verification,
            authorization_handler: authorization_handler
          }
        end
        let(:authorization_handler) do
          {
            document_number: document_number
          }
        end
        let(:document_number) { "12345678X" }
        let(:force_verification) { "" }

        it "verifies the user" do
          expect { patch(:update, params: params) }.to change(Decidim::Authorization, :count).by(1)
                                                                                             .and change(Decidim::ActionLog, :count).by(1)
          expect(response).to have_http_status(:success)
          expect(body).to eq({ "message" => "", "granted" => true, "userId" => user.id, "handler" => "dummy_authorization_handler" })
        end

        context "when vericiation fails" do
          let(:document_number) { "12345678Y" }

          it "does not verify the user" do
            expect { patch(:update, params: params) }.not_to change(Decidim::Authorization, :count)
            expect(response).to have_http_status(:success)
            expect(body).to eq({ "message" => "", "granted" => false, "userId" => user.id, "handler" => "dummy_authorization_handler" })
          end
        end

        context "when force_verification is present" do
          let(:force_verification) { "1" }
          let(:document_number) { "12345678Y" }

          it "forces the verification" do
            expect { patch(:update, params: params) }.to change(Decidim::Authorization, :count).by(1)
                                                                                               .and change(Decidim::ActionLog, :count).by(1)

            expect(response).to have_http_status(:success)
            expect(body).to eq({ "message" => "", "granted" => true, "userId" => user.id, "handler" => "dummy_authorization_handler" })
          end
        end

        context "when a conflict exists" do
          let!(:authorization) { create(:authorization, user: create(:user, organization: organization), name: handler, unique_id: document_number) }

          it "renders conflict template" do
            expect { patch(:update, params: params) }.not_to change(Decidim::Authorization, :count)

            expect(response).to have_http_status(:success)
            expect(body).to eq({ "message" => "", "granted" => false, "userId" => user.id, "handler" => "dummy_authorization_handler" })
          end
        end

        context "when the authorization already exists" do
          let!(:authorization) { create(:authorization, user: user, name: handler) }

          it "does not create a new authorization" do
            expect { patch(:update, params: params) }.to change(Decidim::ActionLog, :count).by(1)
            expect(authorization.reload.unique_id).to eq(document_number)
          end
        end
      end

      describe "DELETE #destroy" do
        let!(:authorization) { create(:authorization, user: user, name: handler) }

        it "destroys the authorization" do
          expect { delete(:destroy, params: params) }.to change(Decidim::Authorization, :count).by(-1)
                                                                                               .and change(Decidim::ActionLog, :count).by(1)
          expect(response).to have_http_status(:success)
          expect(body).to eq({ "message" => "", "granted" => false, "userId" => user.id, "handler" => "dummy_authorization_handler" })
        end

        context "when authorization does not exist" do
          let(:authorization) { nil }

          it "does not destroy the authorization" do
            expect { delete(:destroy, params: params) }.not_to change(Decidim::Authorization, :count)
            expect(response).to have_http_status(:success)
            expect(body).to eq({ "message" => "", "granted" => false, "userId" => user.id, "handler" => "dummy_authorization_handler" })
          end
        end
      end
    end
  end
end
