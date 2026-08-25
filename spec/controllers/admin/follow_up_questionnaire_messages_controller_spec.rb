# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe FollowUpQuestionnaireMessagesController do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, :admin, organization:) }
      let(:component) { create(:component, manifest_name: "surveys", organization:) }
      let(:questionnaire) { create(:questionnaire) }
      let!(:survey) { create(:survey, component:, questionnaire:) }
      let!(:follow_up_questionnaire) do
        Decidim::DecidimAwesome::FollowUpQuestionnaire.create!(decidim_questionnaire_id: questionnaire.id, name: { "en" => "Follow up" })
      end
      let!(:status) do
        Decidim::DecidimAwesome.create_default_statuses!(follow_up_questionnaire)
        follow_up_questionnaire.statuses.first
      end

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user, scope: :user
      end

      describe "GET #index" do
        it "returns http success" do
          get :index, params: { follow_up_questionnaire_id: follow_up_questionnaire.decidim_questionnaire_id }

          expect(response).to have_http_status(:success)
          expect(assigns(:questionnaire)).to eq(questionnaire)
        end
      end

      describe "GET #new" do
        it "returns http success" do
          get :new, params: { follow_up_questionnaire_id: follow_up_questionnaire.decidim_questionnaire_id }

          expect(response).to have_http_status(:success)
          expect(assigns(:form).follow_up_questionnaire_id).to eq(follow_up_questionnaire.id)
        end
      end

      describe "POST #create" do
        let(:respondent) { create(:user, :confirmed, organization:) }
        let(:params) do
          {
            follow_up_questionnaire_id: follow_up_questionnaire.decidim_questionnaire_id,
            follow_up_questionnaire_message: {
              author_id: user.id,
              status_id: status.id,
              body: "Thanks for your feedback",
              decidim_user_id: respondent.id
            }
          }
        end

        it "creates the message" do
          expect { post :create, params: params }.to change(Decidim::DecidimAwesome::FollowUpQuestionnaireMessage, :count).by(1)

          expect(flash[:notice]).not_to be_empty
          expect(response).to redirect_to(follow_up_questionnaire_messages_path(follow_up_questionnaire.decidim_questionnaire_id))
        end

        context "when the form is invalid" do
          let(:params) { super().deep_merge(follow_up_questionnaire_message: { body: "" }) }

          it "renders the new template" do
            expect { post :create, params: params }.not_to change(Decidim::DecidimAwesome::FollowUpQuestionnaireMessage, :count)

            expect(response).to render_template(:new)
          end
        end
      end

      context "when the user has no role in the participatory space" do
        let(:user) { create(:user, :confirmed, organization:) }

        it "is not authorized" do
          get :index, params: { follow_up_questionnaire_id: follow_up_questionnaire.decidim_questionnaire_id }

          expect(response).to have_http_status(:redirect)
          expect(flash[:alert]).to eq("You are not authorized to perform this action.")
        end
      end
    end
  end
end
