# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe FollowUpQuestionnaire do
    subject { follow_up_questionnaire }

    let(:organization) { create(:organization) }
    let(:space) { create(:participatory_process, organization:) }
    let(:component) { create(:component, manifest_name: "surveys", participatory_space: space) }
    let(:questionnaire) { create(:survey, component:).questionnaire }
    let!(:follow_up_questionnaire) { create(:awesome_follow_up_questionnaire, organization:, questionnaire:) }

    it { is_expected.to be_valid }

    it "stores the component of the survey" do
      expect(subject.component).to eq(component)
      expect(subject.participatory_space).to eq(space)
    end

    context "when the component belongs to another organization" do
      before { subject.organization = create(:organization) }

      it { is_expected.not_to be_valid }
    end

    describe ".for_space" do
      let(:other_space) { create(:participatory_process, organization:) }
      let(:other_component) { create(:component, manifest_name: "surveys", participatory_space: other_space) }
      let!(:other_follow_up_questionnaire) { create(:awesome_follow_up_questionnaire, organization:, questionnaire: create(:survey, component: other_component).questionnaire) }

      it "returns only the follow up questionnaires of the space" do
        expect(described_class.for_space(space)).to contain_exactly(follow_up_questionnaire)
        expect(described_class.for_space(other_space)).to contain_exactly(other_follow_up_questionnaire)
      end

      it "excludes the ones of trashed components" do
        component.destroy!
        expect(described_class.for_space(space)).to be_empty
      end
    end

    describe ".visible" do
      it "includes the follow up questionnaire" do
        expect(described_class.visible).to include(follow_up_questionnaire)
      end

      context "when the component is trashed" do
        before { component.destroy! }

        it "excludes the follow up questionnaire" do
          expect(described_class.visible).not_to include(follow_up_questionnaire)
        end

        it "includes it again when the component is restored" do
          Decidim::Component.with_deleted.find(component.id).restore
          expect(described_class.visible).to include(follow_up_questionnaire)
        end
      end
    end
  end
end
