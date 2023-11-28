# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/config_examples"

describe "Questionnaires", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let(:user) do
    create(:user,
           :confirmed,
           organization:)
  end

  let(:meeting) { create(:meeting, :published, :online, :live, component:) }
  let(:meeting_live_event_path) do
    decidim_participatory_process_meetings.meeting_live_event_path(
      participatory_process_slug: participatory_process.slug,
      component_id: component.id,
      meeting_id: meeting.id
    )
  end

  it "does not have current_questionnaire" do
    login_as user, scope: :user
    visit meeting_live_event_path
    expect(page.body).not_to have_content("window.DecidimAwesome.current_questionnaire")
  end

  context "when questionnaire exist" do
    let!(:poll) { create(:poll, meeting:) }
    let!(:questionnaire) { create(:meetings_poll_questionnaire, questionnaire_for: poll) }
    let!(:question_single_option) { create(:meetings_poll_question, :unpublished, questionnaire:) }

    it "has current_questionnaire" do
      login_as user, scope: :user
      visit meeting_live_event_path
      expect(page.body).to have_content("window.DecidimAwesome.current_questionnaire")
    end
  end
end
