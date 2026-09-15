# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe FollowUpQuestionnaireForm do
      subject { described_class.from_params(attributes).with_context(current_organization: organization, existing_questionnaire_ids:) }

      let(:organization) { create(:organization) }
      let(:questionnaire) { create(:questionnaire) }
      let(:existing_questionnaire_ids) { [] }
      let(:attributes) do
        {
          name: { "en" => "Follow up" },
          decidim_questionnaire_id: questionnaire.id,
          position: 0,
          responder_name_field: "full_name",
          responder_email_field: "email",
          active: true
        }
      end

      it { is_expected.to be_valid }

      it "returns the normalized params" do
        expect(subject.to_params).to eq(
          name: { "en" => "Follow up" },
          decidim_questionnaire_id: questionnaire.id,
          position: 0,
          responder_name_field: "full_name",
          responder_email_field: "email",
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

      context "when the questionnaire is already configured" do
        let(:existing_questionnaire_ids) { [questionnaire.id] }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
