# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe FollowUpQuestionnaireMessageStatusChangedEvent do
    subject { described_class.new(resource: message, event_name: event_name, user: user) }

    let(:event_name) { "decidim.events.decidim_awesome.follow_up_questionnaire_message_status_changed" }
    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, organization:) }
    let(:follow_up_questionnaire) do
      Decidim::DecidimAwesome::FollowUpQuestionnaire.create!(decidim_questionnaire_id: create(:questionnaire).id, name: { "en" => "Follow up" })
    end
    let(:status) do
      Decidim::DecidimAwesome.create_default_statuses!(follow_up_questionnaire)
      follow_up_questionnaire.statuses.first
    end
    let(:message) do
      Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.create!(
        follow_up_questionnaire: follow_up_questionnaire,
        status: status,
        author: user,
        decidim_user_id: user.id
      )
    end

    describe "#notification_title" do
      it "includes the questionnaire name and the status" do
        expect(subject.notification_title).to include("Follow up")
        expect(subject.notification_title).to include("Answered")
      end
    end
  end
end
