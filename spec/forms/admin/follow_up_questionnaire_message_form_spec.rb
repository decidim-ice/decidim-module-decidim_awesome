# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe FollowUpQuestionnaireMessageForm do
      subject do
        described_class.from_params(attributes).with_context(
          current_organization: organization,
          current_user: user,
          current_participatory_space: nil,
          statuses_by_id: statuses.index_by(&:id)
        )
      end

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, organization:) }
      let(:follow_up_questionnaire) do
        Decidim::DecidimAwesome::FollowUpQuestionnaire.create!(decidim_questionnaire_id: create(:questionnaire).id, name: { "en" => "Follow up" })
      end
      let(:statuses) do
        Decidim::DecidimAwesome.create_default_statuses!(follow_up_questionnaire)
        follow_up_questionnaire.statuses.reload
      end
      let(:status) { statuses.first }
      let(:respondent) { create(:user, organization:) }
      let(:body) { "Thanks for your feedback" }
      let(:attributes) do
        {
          follow_up_questionnaire_id: follow_up_questionnaire.id,
          status_id: status.id,
          body:,
          author_id: user.id,
          decidim_user_id: respondent.id,
          session_token: nil
        }
      end

      it { is_expected.to be_valid }

      it "returns the normalized params" do
        expect(subject.to_params).to include(
          follow_up_questionnaire_id: follow_up_questionnaire.id,
          status_id: status.id,
          body: "Thanks for your feedback",
          author_id: user.id
        )
      end

      context "when body is blank" do
        let(:body) { "  " }

        it "is valid, since it is the respondent's first message" do
          expect(subject).to be_valid
        end

        context "and the status did not change" do
          before do
            Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.create!(
              follow_up_questionnaire: follow_up_questionnaire,
              status: status,
              author: user,
              decidim_user_id: respondent.id
            )
          end

          it { is_expected.not_to be_valid }
        end

        context "and the status changed" do
          before do
            Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.create!(
              follow_up_questionnaire: follow_up_questionnaire,
              status: statuses.second,
              author: user,
              decidim_user_id: respondent.id
            )
          end

          it { is_expected.to be_valid }
        end
      end

      context "when follow_up_questionnaire_id is missing" do
        let(:attributes) { super().merge(follow_up_questionnaire_id: nil) }

        it { is_expected.not_to be_valid }
      end

      context "when status_id is missing" do
        let(:attributes) { super().merge(status_id: nil) }

        it { is_expected.not_to be_valid }
      end

      context "when the status does not belong to the questionnaire" do
        let(:other_follow_up_questionnaire) do
          Decidim::DecidimAwesome::FollowUpQuestionnaire.create!(decidim_questionnaire_id: create(:questionnaire).id, name: { "en" => "Other" })
        end
        let(:other_status) do
          Decidim::DecidimAwesome.create_default_statuses!(other_follow_up_questionnaire)
          other_follow_up_questionnaire.statuses.first
        end
        let(:attributes) { super().merge(status_id: other_status.id) }

        it { is_expected.not_to be_valid }
      end

      context "when neither decidim_user_id nor session_token is present" do
        let(:attributes) { super().merge(decidim_user_id: nil, session_token: nil) }

        it { is_expected.not_to be_valid }
      end

      context "when session_token is present instead of decidim_user_id" do
        let(:attributes) { super().merge(decidim_user_id: nil, session_token: "some-session-token") }

        it { is_expected.to be_valid }
      end

      context "when the author is not allowed" do
        let(:attributes) { super().merge(author_id: create(:user, organization:).id) }

        it { is_expected.not_to be_valid }
      end

      describe "#possible_authors" do
        it "includes the current user" do
          expect(subject.possible_authors).to include(user)
        end
      end
    end
  end
end
