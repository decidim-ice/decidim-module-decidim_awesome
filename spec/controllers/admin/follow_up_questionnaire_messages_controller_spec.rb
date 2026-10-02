# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe FollowUpQuestionnaireMessagesController do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, :admin, organization:) }
      let(:component) { create(:component, manifest_name: "surveys", organization:) }
      let!(:process_admin_role) { create(:participatory_process_user_role, user:, participatory_process: component.participatory_space, role: "admin") }
      let(:questionnaire) { create(:questionnaire) }
      let!(:survey) { create(:survey, component:, questionnaire:) }
      let!(:follow_up_questionnaire) do
        create(:awesome_follow_up_questionnaire, questionnaire: questionnaire, name: { "en" => "Follow up" }, organization:)
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
        let(:respondent) { create(:user, :confirmed, organization:) }
        let(:anonymous_token) { "anonymous-session-token" }
        let(:last_status) { follow_up_questionnaire.statuses.second }
        let(:params) { { follow_up_questionnaire_id: follow_up_questionnaire.decidim_questionnaire_id } }

        before do
          create(:response, questionnaire:, user: respondent)
          create(:response, questionnaire:, user: nil, session_token: anonymous_token)
          2.times { |i| Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.create!(follow_up_questionnaire:, status:, author: user, body: "Hi", decidim_user_id: respondent.id, created_at: (3 - i).days.ago) }
          Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.create!(follow_up_questionnaire:, status: last_status, author: user, decidim_user_id: respondent.id)
          Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.create!(follow_up_questionnaire:, status:, author: user, body: "Hi", session_token: anonymous_token)
        end

        it "returns http success" do
          get(:index, params:)

          expect(response).to have_http_status(:success)
          expect(assigns(:questionnaire)).to eq(questionnaire)
        end

        it "counts only the messages with body of each respondent" do
          get(:index, params:)

          expect(assigns(:messages_count_by_respondent)[respondent.id]).to eq(2)
          expect(assigns(:messages_count_by_respondent)[anonymous_token]).to eq(1)
        end

        it "returns the last message of each respondent with its status" do
          get(:index, params:)

          latest_messages = assigns(:latest_messages_by_respondent)
          expect(latest_messages.keys).to contain_exactly(respondent.id, anonymous_token)
          expect(latest_messages[respondent.id].body).to be_nil
          expect(latest_messages[respondent.id].association(:status)).to be_loaded
          expect(latest_messages[respondent.id].status).to eq(last_status)
          expect(latest_messages[anonymous_token].body).to eq("Hi")
        end

        context "when a respondent is not in the current page" do
          let(:params) { super().merge(per_page: 15, page: 2) }

          it "does not load their messages" do
            get(:index, params:)

            expect(assigns(:latest_messages_by_respondent)).to be_empty
            expect(assigns(:messages_count_by_respondent)).to be_empty
          end
        end
      end

      context "when the follow up questionnaire has no statuses" do
        let!(:status) { nil }

        it "does not create them" do
          expect { get :index, params: { follow_up_questionnaire_id: follow_up_questionnaire.decidim_questionnaire_id } }.not_to change(Decidim::DecidimAwesome::FollowUpQuestionnaireStatus, :count)
        end
      end

      describe "GET #new" do
        let(:respondent) { create(:user, :confirmed, organization:) }

        before { create(:response, questionnaire:, question: create(:questionnaire_question, questionnaire:), user: respondent) }

        it "returns http success" do
          get :new, params: { follow_up_questionnaire_id: follow_up_questionnaire.decidim_questionnaire_id, decidim_user_id: respondent.id }

          expect(response).to have_http_status(:success)
          expect(assigns(:form).follow_up_questionnaire_id).to eq(follow_up_questionnaire.id)
        end

        context "when the respondent only has a name" do
          render_views

          let(:session_token) { "anonymous-session-token" }
          let(:name_question) { create(:questionnaire_question, questionnaire:) }

          before do
            follow_up_questionnaire.update!(responder_name_field: name_question.id.to_s)
            create(:response, questionnaire:, question: name_question, user: nil, session_token:, body: "Jane")
          end

          it "warns that the message will not be emailed" do
            get :new, params: { follow_up_questionnaire_id: follow_up_questionnaire.decidim_questionnaire_id, session_token: }

            expect(response).to have_http_status(:success)
            expect(response.body).to include("This respondent has no email address")
          end
        end

        context "when the respondent cannot be identified" do
          let(:session_token) { "anonymous-session-token" }

          before { create(:response, questionnaire:, user: nil, session_token:) }

          it "raises a routing error" do
            expect { get :new, params: { follow_up_questionnaire_id: follow_up_questionnaire.decidim_questionnaire_id, session_token: } }
              .to raise_error(ActionController::RoutingError)
          end
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

        before { create(:response, questionnaire:, question: create(:questionnaire_question, questionnaire:), user: respondent) }

        it "creates the message" do
          expect { post :create, params: params }.to change(Decidim::DecidimAwesome::FollowUpQuestionnaireMessage, :count).by(1)

          expect(flash[:notice]).to eq("Message sent successfully")
          expect(response).to redirect_to(follow_up_questionnaire_messages_path(follow_up_questionnaire.decidim_questionnaire_id))
        end

        context "when the respondent only has a name" do
          let(:session_token) { "anonymous-session-token" }
          let(:name_question) { create(:questionnaire_question, questionnaire:) }
          let(:anonymous_params) { params.deep_merge(follow_up_questionnaire_message: { decidim_user_id: nil, session_token: }) }

          before do
            follow_up_questionnaire.update!(responder_name_field: name_question.id.to_s)
            create(:response, questionnaire:, question: name_question, user: nil, session_token:, body: "Jane")
          end

          it "saves the message and tells that it was not emailed" do
            expect { post :create, params: anonymous_params }.to change(Decidim::DecidimAwesome::FollowUpQuestionnaireMessage, :count).by(1)

            expect(flash[:notice]).to eq("Message saved, but not emailed because the respondent has no email address")
          end
        end

        context "when the respondent cannot be identified" do
          let(:session_token) { "anonymous-session-token" }
          let(:anonymous_params) { params.deep_merge(follow_up_questionnaire_message: { decidim_user_id: nil, session_token: }) }

          before { create(:response, questionnaire:, user: nil, session_token:) }

          it "raises a routing error and does not create a message" do
            expect { post :create, params: anonymous_params }.to raise_error(ActionController::RoutingError)
            expect(Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.count).to eq(0)
          end
        end

        context "when the form is invalid" do
          let(:invalid_params) { params.deep_merge(follow_up_questionnaire_message: { status_id: "" }) }

          it "renders the new template" do
            expect { post :create, params: invalid_params }.not_to change(Decidim::DecidimAwesome::FollowUpQuestionnaireMessage, :count)

            expect(response).to render_template(:new)
          end
        end

        context "when the body is blank" do
          let(:blank_body_params) { params.deep_merge(follow_up_questionnaire_message: { body: "" }) }

          def create_previous_message(status:)
            Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.create!(
              follow_up_questionnaire: follow_up_questionnaire,
              status: status,
              author: user,
              decidim_user_id: respondent.id
            )
          end

          context "and the status did not change" do
            before { create_previous_message(status: status) }

            it "does not create a message" do
              expect { post :create, params: blank_body_params }.not_to change(Decidim::DecidimAwesome::FollowUpQuestionnaireMessage, :count)
            end
          end

          context "and the status changed" do
            before { create_previous_message(status: follow_up_questionnaire.statuses.second) }

            it "creates a message with an empty body" do
              expect { post :create, params: blank_body_params }.to change(Decidim::DecidimAwesome::FollowUpQuestionnaireMessage, :count).by(1)
              expect(Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.last.body).to be_blank
            end
          end
        end
      end

      context "when the follow up questionnaire belongs to another organization" do
        let!(:other_follow_up_questionnaire) { create(:awesome_follow_up_questionnaire, organization: create(:organization)) }

        it "raises a routing error" do
          expect { get :index, params: { follow_up_questionnaire_id: other_follow_up_questionnaire.decidim_questionnaire_id } }
            .to raise_error(ActionController::RoutingError)
        end
      end

      context "when the survey component is trashed" do
        before { component.destroy! }

        it "raises a routing error" do
          expect { get :index, params: { follow_up_questionnaire_id: follow_up_questionnaire.decidim_questionnaire_id } }
            .to raise_error(ActionController::RoutingError)
        end
      end

      context "when the user has no role in the participatory space" do
        let(:user) { create(:user, :confirmed, organization:) }
        let(:process_admin_role) { nil }

        it "is not authorized" do
          get :index, params: { follow_up_questionnaire_id: follow_up_questionnaire.decidim_questionnaire_id }

          expect(response).to have_http_status(:redirect)
          expect(flash[:alert]).to eq("You are not authorized to perform this action.")
        end
      end
    end
  end
end
