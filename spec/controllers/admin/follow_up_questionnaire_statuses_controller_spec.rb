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
      let!(:follow_up_questionnaire) { create(:awesome_follow_up_questionnaire, questionnaire: questionnaire, name: { "en" => "Follow up" }, organization:) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user, scope: :user
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

          context "and it only differs in case" do
            before { params[:follow_up_questionnaire_status][:name] = { en: "open" } }

            it "does not create a duplicate status" do
              expect { post :create, params: params }.not_to change(Decidim::DecidimAwesome::FollowUpQuestionnaireStatus, :count)
              expect(flash[:alert]).to include("That name is already used by another label in this questionnaire.")
            end
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

        context "when the name does not change" do
          before { params[:follow_up_questionnaire_status][:name] = { en: "Open" } }

          it "updates the status" do
            patch :update, params: params
            expect(flash[:notice]).not_to be_empty
            expect(status.reload.color).to eq("#FFEBE9")
          end
        end

        context "when the name is taken by another status" do
          before do
            follow_up_questionnaire.statuses.create!(name: { "en" => "Pending" }, color: "#EBF9FF")
            params[:follow_up_questionnaire_status][:name] = { en: "pending" }
          end

          it "does not update the status" do
            patch :update, params: params
            expect(flash[:alert]).to include("That name is already used by another label in this questionnaire.")
            expect(status.reload.name["en"]).to eq("Open")
          end
        end
      end

      describe "DELETE #destroy" do
        let!(:status) { follow_up_questionnaire.statuses.create!(name: { "en" => "Open" }, color: "#EBF9FF") }
        let!(:other_status) { follow_up_questionnaire.statuses.create!(name: { "en" => "Closed" }, color: "#EBF9FF") }

        it "destroys the status" do
          expect { delete :destroy, params: { follow_up_questionnaire_id: follow_up_questionnaire.id, id: status.id } }.to change(Decidim::DecidimAwesome::FollowUpQuestionnaireStatus, :count).by(-1)
          expect(flash[:notice]).not_to be_empty
          expect(response).to redirect_to(edit_follow_up_questionnaire_path(follow_up_questionnaire.decidim_questionnaire_id))
        end

        context "when the status is used in messages" do
          before do
            Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.create!(follow_up_questionnaire:, status:, author: user, decidim_user_id: user.id)
          end

          it "does not destroy the status and shows an alert" do
            expect { delete :destroy, params: { follow_up_questionnaire_id: follow_up_questionnaire.id, id: status.id } }.not_to change(Decidim::DecidimAwesome::FollowUpQuestionnaireStatus, :count)
            expect(flash[:alert]).to eq("This label is used in messages and cannot be removed.")
            expect(response).to redirect_to(edit_follow_up_questionnaire_path(follow_up_questionnaire.decidim_questionnaire_id))
          end
        end

        context "when it is the last status of the questionnaire" do
          let!(:other_status) { nil }

          it "does not destroy the status and shows an alert" do
            expect { delete :destroy, params: { follow_up_questionnaire_id: follow_up_questionnaire.id, id: status.id } }.not_to change(Decidim::DecidimAwesome::FollowUpQuestionnaireStatus, :count)
            expect(flash[:alert]).to eq("At least one label is required, so the last one cannot be removed.")
            expect(response).to redirect_to(edit_follow_up_questionnaire_path(follow_up_questionnaire.decidim_questionnaire_id))
          end
        end
      end

      context "when the form points to another follow-up questionnaire" do
        let(:other_component) { create(:component, manifest_name: "surveys", organization:) }
        let(:other_questionnaire) { create(:questionnaire) }
        let!(:other_survey) { create(:survey, component: other_component, questionnaire: other_questionnaire) }
        let!(:other_follow_up_questionnaire) { create(:awesome_follow_up_questionnaire, questionnaire: other_questionnaire, name: { "en" => "Other" }, organization:) }
        let(:params) do
          {
            follow_up_questionnaire_id: follow_up_questionnaire.id,
            follow_up_questionnaire_status: {
              follow_up_questionnaire_id: other_follow_up_questionnaire.id,
              name: { en: "Open" },
              color: "#EBF9FF"
            }
          }
        end

        it "creates the status in the questionnaire of the URL" do
          expect { post :create, params: params }.to change(follow_up_questionnaire.statuses, :count).by(1)
          expect(other_follow_up_questionnaire.statuses).to be_empty
        end
      end

      context "when the user is a participatory space admin" do
        let(:user) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
        let(:other_process) { create(:participatory_process, organization:) }
        let!(:status) { follow_up_questionnaire.statuses.create!(name: { "en" => "Open" }, color: "#EBF9FF") }

        before { create(:participatory_process_user_role, participatory_process: other_process, user:, role: "admin") }

        it "is not authorized to edit" do
          get :edit, params: { follow_up_questionnaire_id: follow_up_questionnaire.id, id: status.id }

          expect(response).to have_http_status(:redirect)
          expect(flash[:alert]).to eq("You are not authorized to perform this action.")
        end

        it "is not authorized to update" do
          patch :update, params: {
            follow_up_questionnaire_id: follow_up_questionnaire.id,
            id: status.id,
            follow_up_questionnaire_status: { name: { en: "Closed" }, color: "#FFEBE9" }
          }

          expect(flash[:alert]).to eq("You are not authorized to perform this action.")
          expect(status.reload.name["en"]).to eq("Open")
        end

        it "is not authorized to destroy" do
          expect { delete :destroy, params: { follow_up_questionnaire_id: follow_up_questionnaire.id, id: status.id } }
            .not_to change(Decidim::DecidimAwesome::FollowUpQuestionnaireStatus, :count)
          expect(flash[:alert]).to eq("You are not authorized to perform this action.")
        end
      end

      context "when the follow-up questionnaire belongs to another organization" do
        let(:other_organization) { create(:organization) }
        let(:other_component) { create(:component, manifest_name: "surveys", organization: other_organization) }
        let(:other_questionnaire) { create(:questionnaire) }
        let!(:other_survey) { create(:survey, component: other_component, questionnaire: other_questionnaire) }
        let!(:other_follow_up_questionnaire) { create(:awesome_follow_up_questionnaire, questionnaire: other_questionnaire, name: { "en" => "Other" }, organization: other_organization) }
        let!(:status) { other_follow_up_questionnaire.statuses.create!(name: { "en" => "Open" }, color: "#EBF9FF") }

        it "raises a routing error" do
          expect { get :edit, params: { follow_up_questionnaire_id: other_follow_up_questionnaire.id, id: status.id } }
            .to raise_error(ActionController::RoutingError)
        end
      end
    end
  end
end
