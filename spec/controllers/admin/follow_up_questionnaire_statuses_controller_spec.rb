# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe FollowUpQuestionnaireStatusesController do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, :admin, organization:) }
      let(:component) { create(:component, manifest_name: "surveys", organization:) }
      let(:questionnaire) { create(:questionnaire) }
      let!(:survey) { create(:survey, component:, questionnaire:) }
      let!(:follow_up_questionnaire) { Decidim::DecidimAwesome::FollowUpQuestionnaire.create!(decidim_questionnaire_id: questionnaire.id, name: { "en" => "Follow up" }) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user, scope: :user
      end

      describe "GET #index" do
        it "returns http success" do
          get :index, params: { follow_up_questionnaire_id: follow_up_questionnaire.id }
          expect(response).to have_http_status(:success)
        end
      end

      describe "GET #new" do
        it "returns http success" do
          get :new, params: { follow_up_questionnaire_id: follow_up_questionnaire.id }
          expect(response).to have_http_status(:success)
        end
      end

      describe "POST #create" do
        let(:params) do
          {
            follow_up_questionnaire_id: follow_up_questionnaire.id,
            follow_up_questionnaire_status: {
              follow_up_questionnaire_id: follow_up_questionnaire.id,
              name: { en: "Open" },
              color: "#EBF9FF"
            }
          }
        end

        it "creates the status" do
          expect { post :create, params: params }.to change(Decidim::DecidimAwesome::FollowUpQuestionnaireStatus, :count).by(1)
          expect(flash[:notice]).not_to be_empty
          expect(response).to redirect_to(edit_follow_up_questionnaire_path(follow_up_questionnaire.decidim_questionnaire_id))
        end

        context "with invalid parameters" do
          before { params[:follow_up_questionnaire_status][:name] = { en: "" } }

          it "does not create the status" do
            expect { post :create, params: params }.not_to change(Decidim::DecidimAwesome::FollowUpQuestionnaireStatus, :count)
            expect(flash[:alert]).to be_present
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end

        context "when the name is already taken within the questionnaire" do
          let!(:existing_status) { follow_up_questionnaire.statuses.create!(name: { "en" => "Open" }, color: "#EBF9FF") }

          it "does not create a duplicate status" do
            expect { post :create, params: params }.not_to change(Decidim::DecidimAwesome::FollowUpQuestionnaireStatus, :count)
            expect(flash[:alert]).to be_present
          end
        end
      end

      describe "GET #edit" do
        let!(:status) { follow_up_questionnaire.statuses.create!(name: { "en" => "Open" }, color: "#EBF9FF") }

        it "returns http success" do
          get :edit, params: { follow_up_questionnaire_id: follow_up_questionnaire.id, id: status.id }
          expect(response).to have_http_status(:success)
        end

        context "when the status does not exist" do
          it "raises a record not found error" do
            expect { get :edit, params: { follow_up_questionnaire_id: follow_up_questionnaire.id, id: 999_999 } }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      describe "PATCH #update" do
        let!(:status) { follow_up_questionnaire.statuses.create!(name: { "en" => "Open" }, color: "#EBF9FF") }
        let(:params) do
          {
            follow_up_questionnaire_id: follow_up_questionnaire.id,
            id: status.id,
            follow_up_questionnaire_status: {
              follow_up_questionnaire_id: follow_up_questionnaire.id,
              name: { en: "Closed" },
              color: "#FFEBE9"
            }
          }
        end

        it "updates the status" do
          patch :update, params: params
          expect(flash[:notice]).not_to be_empty
          expect(response).to redirect_to(edit_follow_up_questionnaire_path(follow_up_questionnaire.decidim_questionnaire_id))
          expect(status.reload.name["en"]).to eq("Closed")
        end

        context "with invalid parameters" do
          before { params[:follow_up_questionnaire_status][:name] = { en: "" } }

          it "does not update the status" do
            patch :update, params: params
            expect(flash[:alert]).to be_present
            expect(status.reload.name["en"]).not_to eq("")
          end
        end
      end

      describe "DELETE #destroy" do
        let!(:status) { follow_up_questionnaire.statuses.create!(name: { "en" => "Open" }, color: "#EBF9FF") }

        it "destroys the status" do
          expect { delete :destroy, params: { follow_up_questionnaire_id: follow_up_questionnaire.id, id: status.id } }.to change(Decidim::DecidimAwesome::FollowUpQuestionnaireStatus, :count).by(-1)
          expect(flash[:notice]).not_to be_empty
          expect(response).to redirect_to(edit_follow_up_questionnaire_path(follow_up_questionnaire.decidim_questionnaire_id))
        end
      end
    end
  end
end
