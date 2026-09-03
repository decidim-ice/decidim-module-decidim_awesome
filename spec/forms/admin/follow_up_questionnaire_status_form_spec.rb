# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe FollowUpQuestionnaireStatusForm do
      subject { described_class.from_params(attributes).with_context(current_organization: organization, existing_statuses:, current_status_id:) }

      let(:organization) { create(:organization) }
      let(:follow_up_questionnaire) do
        Decidim::DecidimAwesome::FollowUpQuestionnaire.create!(decidim_questionnaire_id: create(:questionnaire).id, name: { "en" => "Follow up" })
      end
      let(:existing_statuses) { [] }
      let(:current_status_id) { nil }
      let(:attributes) do
        {
          follow_up_questionnaire_id: follow_up_questionnaire.id,
          name: { "en" => "Answered" },
          color: "#FFFCE5"
        }
      end

      it { is_expected.to be_valid }

      it "returns the normalized params" do
        expect(subject.to_params).to eq(
          follow_up_questionnaire_id: follow_up_questionnaire.id,
          name: { "en" => "Answered" },
          color: "#FFFCE5"
        )
      end

      context "when follow_up_questionnaire_id is missing" do
        let(:attributes) { super().merge(follow_up_questionnaire_id: nil) }

        it { is_expected.not_to be_valid }
      end

      context "when name is missing" do
        let(:attributes) { super().merge(name: {}) }

        it { is_expected.not_to be_valid }
      end

      context "when color is missing" do
        let(:attributes) { super().merge(color: "") }

        it { is_expected.not_to be_valid }
      end

      context "when color has an invalid format" do
        let(:attributes) { super().merge(color: "yellow") }

        it { is_expected.not_to be_valid }
      end

      context "when the name is already taken within the same questionnaire" do
        let(:existing_status) do
          Decidim::DecidimAwesome::FollowUpQuestionnaireStatus.create!(follow_up_questionnaire:, name: { "en" => "Answered" }, color: "#FFFCE5")
        end
        let(:existing_statuses) { [existing_status] }

        it { is_expected.not_to be_valid }

        context "and it belongs to the status being edited" do
          let(:current_status_id) { existing_status.id }

          it { is_expected.to be_valid }
        end
      end
    end
  end
end
