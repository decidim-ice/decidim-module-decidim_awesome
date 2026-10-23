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
    let(:survey) { create(:survey, :published, allow_responses: true, component:, questionnaire:) }
    let(:questionnaire_path) { Decidim::EngineRouter.main_proxy(component).survey_path(survey) }
    let(:questionnaire) { create(:questionnaire) }
    let!(:question_single_option) { create(:questionnaire_question, :with_response_options, question_type: "single_option", questionnaire:) }
    let!(:question_text) { create(:questionnaire_question, question_type: "short_response", questionnaire:) }

    it "saves answers in local storage" do
      visit questionnaire_path
      expect(page.body).to have_content("window.DecidimAwesome.current_questionnaire")

      within ".response-questionnaire__step" do
        find('input[type="text"]', match: :first).fill_in(with: "My answer")
        find('input[type="radio"]', match: :first).click
      end
      sleep 0.1

      visit questionnaire_path
      sleep 0.1

      within ".response-questionnaire__step" do
        expect(find('input[type="radio"]', match: :first)).to be_checked
        expect(find('input[type="text"]', match: :first).value).to eq("My answer")
      end
    end

    it "exposes the questionnaire_answered flag so the draft can be cleared after submitting" do
      visit questionnaire_path
      expect(page.body).to have_content("window.DecidimAwesome.questionnaire_answered")
    end

    context "when questions have display conditions" do
      let!(:question_single_option) do
        create(:questionnaire_question, question_type: "single_option", questionnaire:, position: 0,
                                        options: [{ "body" => { "en" => "Yes" } }, { "body" => { "en" => "No" } }])
      end
      let!(:question_free_text) do
        create(:questionnaire_question, question_type: "single_option", questionnaire:, position: 4,
                                        options: [{ "body" => { "en" => "Option" } }, { "body" => { "en" => "Other" }, "free_text" => true }])
      end
      let!(:question_conditioned) { create(:questionnaire_question, question_type: "long_response", questionnaire:, position: 1) }
      let!(:question_text) { create(:questionnaire_question, question_type: "short_response", questionnaire:, position: 2) }
      let!(:question_mandatory) { create(:questionnaire_question, question_type: "short_response", questionnaire:, position: 3, mandatory: true) }
      let!(:display_condition) do
        create(:display_condition, condition_type: :equal, question: question_conditioned, condition_question: question_single_option,
                                   response_option: question_single_option.response_options.find_by("body->>'en' = ?", "No"))
      end
      let(:store_id) { "awesome_autosave:v2:edit_questionnaire_#{questionnaire.id}" }

      def within_question(question, &)
        within(".question[data-question-id='#{question.id}']", &)
      end

      def submit_questionnaire
        check "questionnaire_tos_agreement"
        accept_confirm { click_on "Submit" }
      end

      def responses_for(question)
        Decidim::Forms::Response.where(question:)
      end

      it "keeps answers in their questions after a validation error" do
        visit questionnaire_path
        within_question(question_single_option) { choose "Yes" }
        within_question(question_text) { find("input[type='text']").fill_in(with: "text C") }
        submit_questionnaire

        expect(page).to have_content("There was a problem responding")
        expect(page.evaluate_script("window.localStorage.getItem('#{store_id}')")).to be_nil
        within_question(question_text) { expect(find("input[type='text']").value).to eq("text C") }
        within_question(question_mandatory) { expect(find("input[type='text']").value).to eq("") }

        within_question(question_mandatory) { find("input[type='text']").fill_in(with: "text D") }
        submit_questionnaire

        expect(page).to have_no_css("form.response-questionnaire")
        expect(responses_for(question_text).pluck(:body)).to eq(["text C"])
        expect(responses_for(question_mandatory).pluck(:body)).to eq(["text D"])
      end

      it "restores answers in their questions when field indexes change" do
        visit questionnaire_path
        within_question(question_single_option) { choose "Yes" }
        submit_questionnaire

        expect(page).to have_content("There was a problem responding")
        within_question(question_text) { find("input[type='text']").fill_in(with: "text C") }
        within_question(question_single_option) { choose "Yes" }
        sleep 0.1

        visit questionnaire_path
        sleep 0.1

        within_question(question_text) { expect(find("input[type='text']").value).to eq("text C") }
        within_question(question_mandatory) { expect(find("input[type='text']").value).to eq("") }
      end

      it "restores conditional questions and free text options" do
        visit questionnaire_path
        within_question(question_mandatory) { find("input[type='text']").fill_in(with: "text D") }
        within_question(question_single_option) { choose "No" }
        within_question(question_conditioned) { find("textarea").fill_in(with: "My reason") }
        within_question(question_free_text) do
          choose "Other"
          find("input[type='text']").fill_in(with: "My other")
        end
        check "questionnaire_tos_agreement"
        sleep 0.1

        visit questionnaire_path
        sleep 0.1

        within_question(question_conditioned) { expect(find("textarea").value).to eq("My reason") }
        within_question(question_free_text) do
          expect(find("input[type='radio'][value='Other']")).to be_checked
          expect(find("input[type='text']").value).to eq("My other")
        end

        submit_questionnaire

        expect(page).to have_no_css("form.response-questionnaire")
        expect(responses_for(question_conditioned).pluck(:body)).to eq(["My reason"])
        choice = responses_for(question_free_text).first.choices.first
        expect(choice.response_option.body["en"]).to eq("Other")
        expect(choice.custom_body).to eq("My other")
      end
    end

    context "when awesome config is disabled" do
      let!(:awesome_config) { create(:awesome_config, organization:, var: :auto_save_forms, value: false) }

      it "does not save answers in local storage" do
        visit questionnaire_path
        expect(page.body).to have_content("window.DecidimAwesome.current_questionnaire")

        within ".response-questionnaire__step" do
          find('input[type="text"]', match: :first).fill_in(with: "My answer")
          find('input[type="radio"]', match: :first).click
        end
        sleep 0.1

        visit questionnaire_path
        sleep 0.1

        within ".response-questionnaire__step" do
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

        within ".response-questionnaire__step" do
          find('input[type="text"]', match: :first).fill_in(with: "My answer")
          find('input[type="radio"]', match: :first).click
        end
        sleep 0.1

        visit questionnaire_path
        sleep 0.1

        within ".response-questionnaire__step" do
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

        within ".response-questionnaire__step" do
          find('input[type="text"]', match: :first).fill_in(with: "My answer")
          find('input[type="radio"]', match: :first).click
        end
        sleep 0.1

        visit questionnaire_path
        sleep 0.1

        within ".response-questionnaire__step" do
          expect(find('input[type="radio"]', match: :first)).not_to be_checked
          expect(find('input[type="text"]', match: :first).value).to eq("")
        end
      end
    end
  end
end
