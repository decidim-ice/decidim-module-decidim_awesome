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
      let(:name_question) { create(:questionnaire_question, questionnaire:) }
      let(:email_question) { create(:questionnaire_question, questionnaire:) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user, scope: :user
      end

      describe "GET #index" do
        render_views

        let!(:follow_up_questionnaire) do
          create(:awesome_follow_up_questionnaire, questionnaire:, name: { "en" => "Follow up" }, organization:)
        end

        before do
          question = create(:questionnaire_question, questionnaire:)
          create(:response, questionnaire:, question:, session_token: "first")
          create(:response, questionnaire:, question:, session_token: "second")
        end

        it "returns http success" do
          get :index
          expect(response).to have_http_status(:success)
          expect(follow_up_questionnaire.number_of_responses).to eq(2)
        end

        context "when there are follow up questionnaires in another organization" do
          let(:other_organization) { create(:organization) }
          let!(:other_follow_up_questionnaire) { create(:awesome_follow_up_questionnaire, organization: other_organization) }

          it "only lists the ones of the current organization" do
            get :index
            expect(assigns(:follow_up_questionnaires)).to contain_exactly(follow_up_questionnaire)
          end
        end

        context "when the survey component is trashed" do
          before { component.destroy! }

          it "does not list the follow up questionnaire" do
            get :index
            expect(assigns(:follow_up_questionnaires)).to be_empty
          end
        end
      end

      describe "GET #new" do
        it "returns http success" do
          get :new
          expect(response).to have_http_status(:success)
        end

        it "lists the questionnaires available to be linked" do
          get :new
          expect(controller.send(:available_questionnaires)).to include(questionnaire)
        end
      end

      describe "POST #create" do
        let(:params) do
          {
            follow_up_questionnaire: {
              name: { en: "Follow up" },
              decidim_questionnaire_id: questionnaire.id,
              position: 0,
              responder_name_field: name_question.id.to_s,
              responder_email_field: email_question.id.to_s,
              active: true
            }
          }
        end

        it "creates the follow up questionnaire" do
          expect { post :create, params: }.to change(Decidim::DecidimAwesome::FollowUpQuestionnaire, :count).by(1)
          expect(flash[:notice]).not_to be_empty
          expect(response).to redirect_to(follow_up_questionnaires_path)
          expect(Decidim::DecidimAwesome::FollowUpQuestionnaire.last.organization).to eq(organization)
          expect(Decidim::DecidimAwesome::FollowUpQuestionnaire.last.component).to eq(component)
        end

        it "creates the default statuses" do
          post(:create, params:)
          expect(Decidim::DecidimAwesome::FollowUpQuestionnaire.last.statuses.count).to eq(3)
        end

        context "when the questionnaire belongs to another organization" do
          let(:other_component) { create(:component, manifest_name: "surveys", organization: create(:organization)) }
          let(:other_questionnaire) { create(:questionnaire) }
          let!(:other_survey) { create(:survey, component: other_component, questionnaire: other_questionnaire) }

          before { params[:follow_up_questionnaire][:decidim_questionnaire_id] = other_questionnaire.id }

          it "does not create the follow up questionnaire" do
            expect { post :create, params: }.not_to change(Decidim::DecidimAwesome::FollowUpQuestionnaire, :count)
            expect(flash[:alert]).to be_present
            expect(response).to have_http_status(:unprocessable_content)
          end
        end

        context "when the questionnaire is already configured" do
          let!(:existing) { create(:awesome_follow_up_questionnaire, questionnaire:, name: { "en" => "Existing" }, organization:) }

          it "does not create a duplicate and returns an error" do
            expect { post :create, params: }.not_to change(Decidim::DecidimAwesome::FollowUpQuestionnaire, :count)
            expect(flash[:alert]).to be_present
            expect(response).to have_http_status(:unprocessable_content)
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
            expect { post :create, params: }.not_to change(Decidim::DecidimAwesome::FollowUpQuestionnaire, :count)
            expect(flash[:alert]).not_to be_empty
          end

          context "when rendering the form again" do
            render_views

            it "shows the form with the field error" do
              post(:create, params:)
              expect(response).to have_http_status(:unprocessable_content)
              expect(response).to render_template(:new)
              expect(response.body).to include("is-invalid-input")
            end
          end
        end
      end

      describe "GET #edit" do
        let!(:follow_up_questionnaire) { create(:awesome_follow_up_questionnaire, questionnaire:, name: { "en" => "Follow up" }, organization:) }

        it "returns http success" do
          get :edit, params: { id: follow_up_questionnaire.decidim_questionnaire_id }
          expect(response).to have_http_status(:success)
        end

        it "does not create statuses" do
          expect { get :edit, params: { id: follow_up_questionnaire.decidim_questionnaire_id } }.not_to change(Decidim::DecidimAwesome::FollowUpQuestionnaireStatus, :count)
        end

        context "when the follow up questionnaire does not exist" do
          it "raises a routing error" do
            expect { get :edit, params: { id: 999_999 } }.to raise_error(ActionController::RoutingError)
          end
        end

        context "when the follow up questionnaire has messages" do
          render_views

          before do
            Decidim::DecidimAwesome.create_default_statuses!(follow_up_questionnaire)
            Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.create!(
              follow_up_questionnaire:,
              status: follow_up_questionnaire.statuses.first,
              author: user,
              decidim_user_id: user.id
            )
          end

          it "disables the survey select and shows a warning" do
            get :edit, params: { id: follow_up_questionnaire.decidim_questionnaire_id }
            expect(response.body).to include("This follow-up already has messages sent to respondents")
            expect(response.body).to match(/<select[^>]*disabled[^>]*name="follow_up_questionnaire\[decidim_questionnaire_id\]"|<select[^>]*name="follow_up_questionnaire\[decidim_questionnaire_id\]"[^>]*disabled/)
          end
        end

        context "when the follow up questionnaire belongs to another organization" do
          let!(:other_follow_up_questionnaire) { create(:awesome_follow_up_questionnaire, organization: create(:organization)) }

          it "raises a routing error" do
            expect { get :edit, params: { id: other_follow_up_questionnaire.decidim_questionnaire_id } }.to raise_error(ActionController::RoutingError)
          end
        end

        context "when the survey component is trashed" do
          before { component.destroy! }

          it "raises a routing error" do
            expect { get :edit, params: { id: follow_up_questionnaire.decidim_questionnaire_id } }.to raise_error(ActionController::RoutingError)
          end
        end
      end

      describe "PATCH #update" do
        let!(:follow_up_questionnaire) { create(:awesome_follow_up_questionnaire, questionnaire:, name: { "en" => "Follow up" }, organization:) }
        let(:params) do
          {
            id: follow_up_questionnaire.decidim_questionnaire_id,
            follow_up_questionnaire: {
              name: { en: "Updated name" },
              decidim_questionnaire_id: questionnaire.id,
              position: 1,
              responder_name_field: name_question.id.to_s,
              responder_email_field: email_question.id.to_s,
              active: false
            }
          }
        end

        it "updates the follow up questionnaire" do
          patch(:update, params:)
          expect(flash[:notice]).not_to be_empty
          expect(response).to redirect_to(follow_up_questionnaires_path)
          expect(follow_up_questionnaire.reload.name["en"]).to eq("Updated name")
        end

        context "when the follow up questionnaire has messages and the questionnaire changes" do
          let(:other_component) { create(:component, manifest_name: "surveys", organization:) }
          let(:other_questionnaire) { create(:survey, component: other_component).questionnaire }

          before do
            Decidim::DecidimAwesome.create_default_statuses!(follow_up_questionnaire)
            Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.create!(
              follow_up_questionnaire:,
              status: follow_up_questionnaire.statuses.first,
              author: user,
              decidim_user_id: user.id
            )
            params[:follow_up_questionnaire][:decidim_questionnaire_id] = other_questionnaire.id
          end

          it "keeps the questionnaire and component and updates the rest" do
            patch(:update, params:)
            follow_up_questionnaire.reload
            expect(follow_up_questionnaire.questionnaire).to eq(questionnaire)
            expect(follow_up_questionnaire.component).to eq(component)
            expect(follow_up_questionnaire.name["en"]).to eq("Updated name")
          end
        end

        context "when the questionnaire changes" do
          let(:other_component) { create(:component, manifest_name: "surveys", organization:) }
          let(:other_questionnaire) { create(:survey, component: other_component).questionnaire }

          before do
            params[:follow_up_questionnaire].merge!(decidim_questionnaire_id: other_questionnaire.id, responder_name_field: "", responder_email_field: "")
          end

          it "updates the component" do
            patch(:update, params:)
            expect(follow_up_questionnaire.reload.component).to eq(other_component)
          end
        end

        context "with invalid parameters" do
          before { params[:follow_up_questionnaire][:name] = { en: "" } }

          it "does not update the follow up questionnaire" do
            patch(:update, params:)
            expect(flash[:alert]).not_to be_empty
            expect(follow_up_questionnaire.reload.name["en"]).not_to eq("")
          end

          context "when rendering the form again" do
            render_views

            it "shows the form with the field error" do
              patch(:update, params:)
              expect(response).to have_http_status(:unprocessable_content)
              expect(response).to render_template(:edit)
              expect(response.body).to include("is-invalid-input")
            end
          end
        end
      end

      describe "DELETE #destroy" do
        let!(:follow_up_questionnaire) { create(:awesome_follow_up_questionnaire, questionnaire:, name: { "en" => "Follow up" }, organization:) }

        it "destroys the follow up questionnaire" do
          expect { delete :destroy, params: { id: follow_up_questionnaire.decidim_questionnaire_id } }.to change(Decidim::DecidimAwesome::FollowUpQuestionnaire, :count).by(-1)
          expect(flash[:notice]).not_to be_empty
          expect(response).to redirect_to(follow_up_questionnaires_path)
        end

        it "does not create statuses" do
          expect(Decidim::DecidimAwesome).not_to receive(:create_default_statuses!)
          delete :destroy, params: { id: follow_up_questionnaire.decidim_questionnaire_id }
        end

        context "when the follow up questionnaire has messages" do
          before do
            Decidim::DecidimAwesome.create_default_statuses!(follow_up_questionnaire)
            Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.create!(
              follow_up_questionnaire:,
              status: follow_up_questionnaire.statuses.first,
              author: user,
              decidim_user_id: user.id
            )
          end

          it "does not destroy the follow up questionnaire and shows the translated error" do
            expect { delete :destroy, params: { id: follow_up_questionnaire.decidim_questionnaire_id } }.not_to change(Decidim::DecidimAwesome::FollowUpQuestionnaire, :count)
            expect(flash[:alert]).to include("It has messages sent to respondents and cannot be removed.")
            expect(response).to redirect_to(follow_up_questionnaires_path)
          end
        end
      end
    end
  end
end
