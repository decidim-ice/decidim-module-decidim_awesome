# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe FollowUpQuestionnairesController do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, :admin, organization:) }
      let(:component) { create(:component, manifest_name: "surveys", organization:) }
      let(:questionnaire) { create(:questionnaire) }
      let!(:survey) { create(:survey, component:, questionnaire:) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user, scope: :user
      end

      describe "GET #index" do
        it "returns http success" do
          get :index
          expect(response).to have_http_status(:success)
        end
      end

      describe "GET #new" do
        it "returns http success" do
          get :new
          expect(response).to have_http_status(:success)
        end

        it "lists the questionnaires available to be linked" do
          get :new
          expect(assigns(:available_questionnaires)).to include(questionnaire)
        end
      end

      describe "POST #create" do
        let(:params) do
          {
            follow_up_questionnaire: {
              name: { en: "Follow up" },
              decidim_questionnaire_id: questionnaire.id,
              position: 0,
              responder_name_field: "full_name",
              responder_email_field: "email",
              active: true
            }
          }
        end

        it "creates the follow up questionnaire" do
          expect { post :create, params: params }.to change(Decidim::DecidimAwesome::FollowUpQuestionnaire, :count).by(1)
          expect(flash[:notice]).not_to be_empty
          expect(response).to redirect_to(follow_up_questionnaires_path)
        end

        context "when the questionnaire is already configured" do
          let!(:existing) { Decidim::DecidimAwesome::FollowUpQuestionnaire.create!(decidim_questionnaire_id: questionnaire.id, name: { "en" => "Existing" }) }

          it "does not create a duplicate and returns an error" do
            expect { post :create, params: params }.not_to change(Decidim::DecidimAwesome::FollowUpQuestionnaire, :count)
            expect(flash[:alert]).to be_present
            expect(response).to have_http_status(:ok)
          end
        end

        context "with invalid parameters" do
          let(:params) do
            {
              follow_up_questionnaire: {
                name: { en: "" },
                decidim_questionnaire_id: questionnaire.id
              }
            }
          end

          it "does not create the follow up questionnaire" do
            expect { post :create, params: params }.not_to change(Decidim::DecidimAwesome::FollowUpQuestionnaire, :count)
            expect(flash[:alert]).not_to be_empty
          end
        end
      end

      describe "GET #edit" do
        let!(:follow_up_questionnaire) { Decidim::DecidimAwesome::FollowUpQuestionnaire.create!(decidim_questionnaire_id: questionnaire.id, name: { "en" => "Follow up" }) }

        it "returns http success" do
          get :edit, params: { id: follow_up_questionnaire.decidim_questionnaire_id }
          expect(response).to have_http_status(:success)
        end

        context "when the follow up questionnaire does not exist" do
          it "raises a routing error" do
            expect { get :edit, params: { id: 999_999 } }.to raise_error(ActionController::RoutingError)
          end
        end
      end

      describe "PATCH #update" do
        let!(:follow_up_questionnaire) { Decidim::DecidimAwesome::FollowUpQuestionnaire.create!(decidim_questionnaire_id: questionnaire.id, name: { "en" => "Follow up" }) }
        let(:params) do
          {
            id: follow_up_questionnaire.decidim_questionnaire_id,
            follow_up_questionnaire: {
              name: { en: "Updated name" },
              decidim_questionnaire_id: questionnaire.id,
              position: 1,
              responder_name_field: "full_name",
              responder_email_field: "email",
              active: false
            }
          }
        end

        it "updates the follow up questionnaire" do
          patch :update, params: params
          expect(flash[:notice]).not_to be_empty
          expect(response).to redirect_to(follow_up_questionnaires_path)
          expect(follow_up_questionnaire.reload.name["en"]).to eq("Updated name")
        end

        context "with invalid parameters" do
          before { params[:follow_up_questionnaire][:name] = { en: "" } }

          it "does not update the follow up questionnaire" do
            patch :update, params: params
            expect(flash[:alert]).not_to be_empty
            expect(follow_up_questionnaire.reload.name["en"]).not_to eq("")
          end
        end
      end

      describe "DELETE #destroy" do
        let!(:follow_up_questionnaire) { Decidim::DecidimAwesome::FollowUpQuestionnaire.create!(decidim_questionnaire_id: questionnaire.id, name: { "en" => "Follow up" }) }

        it "destroys the follow up questionnaire" do
          expect { delete :destroy, params: { id: follow_up_questionnaire.decidim_questionnaire_id } }.to change(Decidim::DecidimAwesome::FollowUpQuestionnaire, :count).by(-1)
          expect(flash[:notice]).not_to be_empty
          expect(response).to redirect_to(follow_up_questionnaires_path)
        end
      end
    end
  end
end
