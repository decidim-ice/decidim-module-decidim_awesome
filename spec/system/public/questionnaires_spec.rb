# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/config_examples"

describe "Questionnaires" do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let(:user) do
    create(:user,
           :confirmed,
           organization:)
  end

  let(:meeting) { create(:meeting, :published, :online, :live, component:) }
  let(:questionnaire_path) { Decidim::EngineRouter.main_proxy(component).meeting_live_event_path(meeting) }

  before do
    login_as user, scope: :user
  end

  it "does not have current_questionnaire" do
    visit questionnaire_path
    expect(page.body).to have_no_content("window.DecidimAwesome.current_questionnaire")
  end

  context "when questionnaire exist" do
    let!(:poll) { create(:poll, meeting:) }
    let!(:questionnaire) { create(:meetings_poll_questionnaire, questionnaire_for: poll) }
    let!(:question_single_option) { create(:meetings_poll_question, :published, questionnaire:) }

    it "has current_questionnaire" do
      visit questionnaire_path
      expect(page.body).to have_content("window.DecidimAwesome.current_questionnaire")
    end
  end

  context "when surveys" do
    let(:manifest_name) { "surveys" }
    let(:survey) { create(:survey, component:, questionnaire:) }
    let(:questionnaire_path) { Decidim::EngineRouter.main_proxy(component).survey_path(survey) }
    let(:questionnaire) { create(:questionnaire) }
    let!(:question_single_option) { create(:questionnaire_question, :with_answer_options, question_type: "single_option", questionnaire:) }
    let!(:question_text) { create(:questionnaire_question, question_type: "short_answer", questionnaire:) }

    it "saves answers in local storage" do
      visit questionnaire_path
      expect(page.body).to have_content("window.DecidimAwesome.current_questionnaire")

      within ".answer-questionnaire__step" do
        find('input[type="text"]', match: :first).fill_in(with: "My answer")
        find('input[type="radio"]', match: :first).click
      end
      sleep 0.1

      visit questionnaire_path
      sleep 0.1

      within ".answer-questionnaire__step" do
        expect(find('input[type="radio"]', match: :first)).to be_checked
        expect(find('input[type="text"]', match: :first).value).to eq("My answer")
      end
    end

    context "when awesome config is disabled" do
      let!(:awesome_config) { create(:awesome_config, organization:, var: :auto_save_forms, value: false) }

      it "does not save answers in local storage" do
        visit questionnaire_path
        expect(page.body).to have_content("window.DecidimAwesome.current_questionnaire")

        within ".answer-questionnaire__step" do
          find('input[type="text"]', match: :first).fill_in(with: "My answer")
          find('input[type="radio"]', match: :first).click
        end
        sleep 0.1

        visit questionnaire_path
        sleep 0.1

        within ".answer-questionnaire__step" do
          expect(find('input[type="radio"]', match: :first)).not_to be_checked
          expect(find('input[type="text"]', match: :first).value).to eq("")
        end
      end
    end

    context "when awesome config is scoped to the current participatory space" do
      let!(:awesome_config) { create(:awesome_config, organization:, var: :auto_save_forms) }
      let!(:awesome_constraint) { create(:config_constraint, awesome_config:, settings: { participatory_space_slug: component.participatory_space.slug }) }

      it "saves answers in local storage" do
        visit questionnaire_path
        expect(page.body).to have_content("window.DecidimAwesome.current_questionnaire")

        within ".answer-questionnaire__step" do
          find('input[type="text"]', match: :first).fill_in(with: "My answer")
          find('input[type="radio"]', match: :first).click
        end
        sleep 0.1

        visit questionnaire_path
        sleep 0.1

        within ".answer-questionnaire__step" do
          expect(find('input[type="radio"]', match: :first)).to be_checked
          expect(find('input[type="text"]', match: :first).value).to eq("My answer")
        end
      end
    end

    context "when awesome config is scoped to another participatory space" do
      let!(:awesome_config) { create(:awesome_config, organization:, var: :auto_save_forms) }
      let!(:awesome_constraint) { create(:config_constraint, awesome_config:, settings: { participatory_space_slug: "other-slug" }) }

      it "does not save answers in local storage" do
        visit questionnaire_path
        expect(page.body).to have_content("window.DecidimAwesome.current_questionnaire")

        within ".answer-questionnaire__step" do
          find('input[type="text"]', match: :first).fill_in(with: "My answer")
          find('input[type="radio"]', match: :first).click
        end
        sleep 0.1

        visit questionnaire_path
        sleep 0.1

        within ".answer-questionnaire__step" do
          expect(find('input[type="radio"]', match: :first)).not_to be_checked
          expect(find('input[type="text"]', match: :first).value).to eq("")
        end
      end
    end
  end
end
