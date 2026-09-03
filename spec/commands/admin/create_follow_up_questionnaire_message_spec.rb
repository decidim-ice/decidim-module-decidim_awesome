# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe CreateFollowUpQuestionnaireMessage do
      subject { described_class.new(form) }

      include ActiveJob::TestHelper

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, organization:) }
      let(:respondent) { create(:user, :confirmed, organization:) }
      let(:questionnaire) { create(:questionnaire) }
      let(:follow_up_questionnaire) do
        Decidim::DecidimAwesome::FollowUpQuestionnaire.create!(decidim_questionnaire_id: questionnaire.id, name: { "en" => "Follow up" })
      end
      let(:statuses) do
        Decidim::DecidimAwesome.create_default_statuses!(follow_up_questionnaire)
        follow_up_questionnaire.statuses.reload
      end
      let(:status) { statuses.first }
      let(:decidim_user_id) { respondent.id }
      let(:session_token) { nil }
      let(:body) { "Thanks for your feedback" }
      let(:context) do
        {
          current_user: user,
          current_organization: organization,
          current_participatory_space: nil,
          statuses_by_id: statuses.index_by(&:id)
        }
      end
      let(:params) do
        {
          follow_up_questionnaire_id: follow_up_questionnaire.id,
          status_id: status.id,
          body:,
          author_id: user.id,
          decidim_user_id:,
          session_token:
        }
      end
      let(:form) { FollowUpQuestionnaireMessageForm.from_params(params).with_context(context) }
      let(:message) { Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.last }

      before { clear_enqueued_jobs }

      context "when the form is valid" do
        it "broadcasts :ok and creates the message" do
          expect { subject.call }.to broadcast(:ok)

          expect(message.follow_up_questionnaire).to eq(follow_up_questionnaire)
          expect(message.status).to eq(status)
          expect(message.body).to eq("Thanks for your feedback")
          expect(message.author).to eq(user)
          expect(message.decidim_user_id).to eq(respondent.id)
        end

        it "notifies the respondent by email" do
          expect { subject.call }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
        end

        context "and the respondent cannot be identified" do
          let(:decidim_user_id) { nil }
          let(:session_token) { "some-session-token" }

          it "does not send any notification" do
            expect { subject.call }.to broadcast(:ok)
            expect { subject.call }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
          end
        end
      end

      context "when the body is blank and the status did not change" do
        let(:body) { "" }

        before do
          Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.create!(
            follow_up_questionnaire: follow_up_questionnaire,
            status: status,
            author: user,
            decidim_user_id: respondent.id
          )
        end

        it "broadcasts :invalid and does not create a new message" do
          expect { subject.call }.to broadcast(:invalid)
          expect(Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.count).to eq(1)
        end
      end

      context "when the body is blank and the status changed" do
        let(:body) { "" }

        before do
          Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.create!(
            follow_up_questionnaire: follow_up_questionnaire,
            status: statuses.second,
            author: user,
            decidim_user_id: respondent.id
          )
        end

        it "creates the message with an empty body, sends the email and notifies in-app" do
          expect(Decidim::EventsManager).to receive(:publish).with(
            event: "decidim.events.decidim_awesome.follow_up_questionnaire_message_status_changed",
            event_class: FollowUpQuestionnaireMessageStatusChangedEvent,
            resource: an_instance_of(Decidim::DecidimAwesome::FollowUpQuestionnaireMessage),
            affected_users: [respondent]
          )

          expect { subject.call }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
          expect(message.body).to be_nil
        end
      end

      context "when the body is present and the status changed" do
        before do
          Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.create!(
            follow_up_questionnaire: follow_up_questionnaire,
            status: statuses.second,
            author: user,
            decidim_user_id: respondent.id
          )
        end

        it "sends the email and notifies the respondent in-app" do
          expect(Decidim::EventsManager).to receive(:publish).with(
            event: "decidim.events.decidim_awesome.follow_up_questionnaire_message_status_changed",
            event_class: FollowUpQuestionnaireMessageStatusChangedEvent,
            resource: an_instance_of(Decidim::DecidimAwesome::FollowUpQuestionnaireMessage),
            affected_users: [respondent]
          )

          expect { subject.call }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
        end
      end

      context "when the body is present and the status did not change" do
        before do
          Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.create!(
            follow_up_questionnaire: follow_up_questionnaire,
            status: status,
            author: user,
            decidim_user_id: respondent.id
          )
        end

        it "sends the email but does not notify in-app" do
          expect(Decidim::EventsManager).not_to receive(:publish)

          expect { subject.call }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
        end
      end

      context "when a different author is selected" do
        let(:other_admin) { create(:user, :confirmed, organization:) }
        let(:params) { super().merge(author_id: other_admin.id) }

        before { allow(form).to receive(:possible_authors).and_return([user, other_admin]) }

        it "creates the message with the selected author" do
          expect { subject.call }.to broadcast(:ok)
          expect(message.author).to eq(other_admin)
        end
      end

      context "when the status does not belong to the questionnaire" do
        let(:other_follow_up_questionnaire) do
          Decidim::DecidimAwesome::FollowUpQuestionnaire.create!(decidim_questionnaire_id: create(:questionnaire).id, name: { "en" => "Other" })
        end
        let(:other_status) do
          Decidim::DecidimAwesome.create_default_statuses!(other_follow_up_questionnaire)
          other_follow_up_questionnaire.statuses.first
        end
        let(:params) { super().merge(status_id: other_status.id) }

        it "broadcasts :invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when the author is not allowed" do
        let(:params) { super().merge(author_id: create(:user, organization:).id) }

        it "broadcasts :invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end
    end
  end
end
