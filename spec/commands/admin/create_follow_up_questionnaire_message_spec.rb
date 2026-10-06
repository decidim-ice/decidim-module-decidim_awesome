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
      let(:component) { create(:component, manifest_name: "surveys", organization:) }
      let(:questionnaire) { create(:questionnaire) }
      let!(:survey) { create(:survey, component:, questionnaire:) }
      let(:follow_up_questionnaire) do
        create(:awesome_follow_up_questionnaire, questionnaire:, name: { "en" => "Follow up" }, organization:)
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

        it "notifies the respondent by email without a Reply-To" do
          expect { subject.call }.to have_enqueued_job(ActionMailer::MailDeliveryJob)

          perform_enqueued_jobs
          expect(ActionMailer::Base.deliveries.last.reply_to).to be_nil
        end

        it "reports that the email was sent" do
          email_sent = nil
          described_class.call(form) { on(:ok) { |_message, sent| email_sent = sent } }

          expect(email_sent).to be(true)
        end

        context "and the respondent only has a name" do
          let(:decidim_user_id) { nil }
          let(:session_token) { "anonymous-session-token" }
          let(:name_question) { create(:questionnaire_question, questionnaire:) }

          before do
            follow_up_questionnaire.update!(responder_name_field: name_question.id.to_s)
            create(:response, questionnaire:, question: name_question, user: nil, session_token:, body: "Jane")
          end

          it "saves the message without emailing it and reports it" do
            email_sent = nil

            expect { described_class.call(form) { on(:ok) { |_message, sent| email_sent = sent } } }
              .to change(Decidim::DecidimAwesome::FollowUpQuestionnaireMessage, :count).by(1)
            expect(email_sent).to be(false)
            expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
          end
        end

        context "when the follow up questionnaire has a Reply-To email" do
          before { follow_up_questionnaire.update!(reply_to: "replies@example.org") }

          it "uses it as the Reply-To of the email" do
            subject.call
            perform_enqueued_jobs
            expect(ActionMailer::Base.deliveries.last.reply_to).to eq(["replies@example.org"])
          end
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

      context "when the body is blank and it is the respondent's first message" do
        let(:body) { "" }

        it "treats it as a status change, sending the email with the status and notifying in-app" do
          expect(Decidim::EventsManager).to receive(:publish).with(
            event: "decidim.events.decidim_awesome.follow_up_questionnaire_message_status_changed",
            event_class: FollowUpQuestionnaireMessageStatusChangedEvent,
            resource: an_instance_of(Decidim::DecidimAwesome::FollowUpQuestionnaireMessage),
            affected_users: [respondent]
          )

          expect { subject.call }.to broadcast(:ok)
          expect(message.body).to be_nil

          perform_enqueued_jobs
          expect(ActionMailer::Base.deliveries.last.html_part.body.to_s).to include("Status updated to")
        end
      end

      context "when the body is blank and the status did not change" do
        let(:body) { "" }

        before do
          Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.create!(
            follow_up_questionnaire:,
            status:,
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
            follow_up_questionnaire:,
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
            follow_up_questionnaire:,
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
            follow_up_questionnaire:,
            status:,
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
          create(:awesome_follow_up_questionnaire, questionnaire: create(:questionnaire), name: { "en" => "Other" }, organization:)
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
