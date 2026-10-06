# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe FollowUpQuestionnaireMessageStatusChangedEvent do
    subject { described_class.new(resource: message, event_name:, user:) }

    let(:event_name) { "decidim.events.decidim_awesome.follow_up_questionnaire_message_status_changed" }
    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, organization:) }
    let(:follow_up_questionnaire) { create(:awesome_follow_up_questionnaire, name: { "en" => "Follow up" }, organization:) }
    let(:survey) { follow_up_questionnaire.questionnaire.questionnaire_for }
    let(:status) do
      Decidim::DecidimAwesome.create_default_statuses!(follow_up_questionnaire)
      follow_up_questionnaire.statuses.first
    end
    let(:message) do
      Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.create!(
        follow_up_questionnaire:,
        status:,
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

    describe "#resource_path" do
      it "points to the linked survey" do
        expect(subject.resource_path).to eq(Decidim::ResourceLocatorPresenter.new(survey).path)
      end
    end

    describe "#resource_url" do
      it "points to the linked survey" do
        expect(subject.resource_url).to eq(Decidim::ResourceLocatorPresenter.new(survey).url)
      end
    end

    describe "#resource_title" do
      it "is the follow up questionnaire name" do
        expect(subject.resource_title).to eq("Follow up")
      end
    end

    describe "push notifications" do
      let(:notification) { create(:notification, user:, resource: message, event_name:, event_class: described_class.name) }

      it "links to the linked survey" do
        expect(Decidim::PushNotificationPresenter.new(notification).url).to eq(Decidim::ResourceLocatorPresenter.new(survey).url)
      end
    end
  end
end
