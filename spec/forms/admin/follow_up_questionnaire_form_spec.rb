# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe FollowUpQuestionnaireForm do
      subject { described_class.from_params(attributes).with_context(current_organization: organization, existing_questionnaire_ids:) }

      let(:organization) { create(:organization) }
      let(:component) { create(:component, manifest_name: "surveys", organization:) }
      let(:questionnaire) { create(:questionnaire) }
      let!(:survey) { create(:survey, component:, questionnaire:) }
      let(:existing_questionnaire_ids) { [] }
      let(:name_question) { create(:questionnaire_question, questionnaire:) }
      let(:email_question) { create(:questionnaire_question, questionnaire:) }
      let(:attributes) do
        {
          name: { "en" => "Follow up" },
          decidim_questionnaire_id: questionnaire.id,
          position: 0,
          responder_name_field: name_question.id.to_s,
          responder_email_field: email_question.id.to_s,
          active: true
        }
      end

      it { is_expected.to be_valid }

      it "returns the normalized params" do
        expect(subject.to_params).to eq(
          name: { "en" => "Follow up" },
          decidim_questionnaire_id: questionnaire.id,
          position: 0,
          responder_name_field: name_question.id.to_s,
          responder_email_field: email_question.id.to_s,
          reply_to: nil,
          active: true
        )
      end

      context "when name is missing" do
        let(:attributes) { super().merge(name: {}) }

        it { is_expected.not_to be_valid }
      end

      context "when decidim_questionnaire_id is missing" do
        let(:attributes) { super().merge(decidim_questionnaire_id: nil) }

        it { is_expected.not_to be_valid }
      end

      context "when position is negative" do
        let(:attributes) { super().merge(position: -1) }

        it { is_expected.not_to be_valid }
      end

      context "when the questionnaire belongs to another organization" do
        let(:component) { create(:component, manifest_name: "surveys", organization: create(:organization)) }

        it { is_expected.not_to be_valid }
      end

      context "when the questionnaire does not belong to any component" do
        let!(:survey) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when the questionnaire is already configured" do
        let(:existing_questionnaire_ids) { [questionnaire.id] }

        it { is_expected.not_to be_valid }
      end

      context "when the responder fields are blank" do
        let(:attributes) { super().merge(responder_name_field: "", responder_email_field: nil) }

        it { is_expected.to be_valid }
      end

      context "when a responder field is a question of another questionnaire" do
        let(:other_question) { create(:questionnaire_question, questionnaire: create(:questionnaire)) }
        let(:attributes) { super().merge(responder_email_field: other_question.id.to_s) }

        it "is not valid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:responder_email_field]).to be_present
          expect(subject.errors[:responder_name_field]).to be_empty
        end
      end

      context "when a responder field is not a question id" do
        let(:attributes) { super().merge(responder_name_field: "full_name") }

        it "is not valid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:responder_name_field]).to be_present
        end
      end
    end
  end
end
