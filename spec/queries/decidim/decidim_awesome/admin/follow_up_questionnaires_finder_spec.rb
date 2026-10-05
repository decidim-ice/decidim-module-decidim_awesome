# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe FollowUpQuestionnairesFinder do
      subject { described_class.new(organization, excluding:) }

      let(:excluding) { nil }
      let(:organization) { create(:organization) }
      let(:participatory_space) { create(:participatory_process, organization:) }
      let(:component) { create(:component, manifest_name: "surveys", participatory_space:) }
      let(:questionnaire) { create(:questionnaire) }
      let!(:survey) { create(:survey, component:, questionnaire:) }

      let(:other_component) { create(:component, manifest_name: "surveys", organization: create(:organization)) }
      let(:other_questionnaire) { create(:questionnaire) }
      let!(:other_survey) { create(:survey, component: other_component, questionnaire: other_questionnaire) }

      let(:meeting_component) { create(:meeting_component, participatory_space:) }
      let(:meeting) { create(:meeting, component: meeting_component) }
      let!(:meeting_questionnaire) { meeting.questionnaire }

      let!(:space_questionnaire) { create(:questionnaire, questionnaire_for: participatory_space) }

      describe "#query" do
        it "returns the questionnaires of surveys and meetings in the organization" do
          expect(subject.query).to contain_exactly(questionnaire, meeting_questionnaire)
        end

        it "preloads what the form needs" do
          result = subject.query.find { |item| item == questionnaire }

          expect(result.association(:questions)).to be_loaded
          expect(result.association(:questionnaire_for)).to be_loaded
          expect(result.questionnaire_for.association(:component)).to be_loaded
        end

        context "when a questionnaire is already configured" do
          let!(:follow_up_questionnaire) { create(:awesome_follow_up_questionnaire, questionnaire:, organization:) }

          it "is not returned" do
            expect(subject.query).to contain_exactly(meeting_questionnaire)
          end

          context "and it is the one being edited" do
            let(:excluding) { follow_up_questionnaire.id }

            it "is returned" do
              expect(subject.query).to contain_exactly(questionnaire, meeting_questionnaire)
            end
          end
        end
      end

      describe "#component_for" do
        it "returns the component of a questionnaire in the organization" do
          expect(subject.component_for(questionnaire)).to eq(component)
        end

        it "returns nil for a questionnaire of another organization" do
          expect(subject.component_for(other_questionnaire)).to be_nil
        end
      end
    end
  end
end
