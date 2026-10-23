# frozen_string_literal: true

require "spec_helper"

describe "Admin notifications for follow-up questionnaire responses" do
  let(:organization) { create(:organization) }
  let(:component) { create(:component, manifest_name: "surveys", organization:) }
  let(:participatory_process) { component.participatory_space }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let!(:space_admin) { create(:user, :confirmed, organization:) }
  let!(:space_admin_role) { create(:participatory_process_user_role, user: space_admin, participatory_process:, role: "admin") }
  let!(:participant) { create(:user, :confirmed, organization:) }
  let!(:questionnaire) { create(:questionnaire) }
  let!(:question) { create(:questionnaire_question, questionnaire:, question_type: "short_response", position: 0, body: { "en" => "What is your name?" }) }
  let!(:survey) { create(:survey, :published, :allow_responses, component:, questionnaire:) }
  let!(:follow_up_questionnaire) { create(:awesome_follow_up_questionnaire, questionnaire:, organization:, name: { "en" => "Follow up" }) }
  let(:admins_select) { "#follow_up_questionnaire_notified_admin_ids" }
  let(:messages_path) { decidim_admin_decidim_awesome.follow_up_questionnaire_messages_path(questionnaire.id) }

  before do
    switch_to_host(organization.host)
  end

  it "notifies the selected admins when a participant responds the survey" do
    login_as admin, scope: :user
    visit decidim_admin_decidim_awesome.edit_follow_up_questionnaire_path(questionnaire.id)

    option_values = all("#{admins_select} option", visible: :all).map(&:value)
    expect(option_values).to include(admin.id.to_s, space_admin.id.to_s)
    expect(option_values).not_to include(participant.id.to_s)

    tom_select(admins_select, option_id: [space_admin.id.to_s])
    click_on "Save"

    expect(page).to have_content("Follow-up questionnaire updated successfully")
    expect(follow_up_questionnaire.reload.notified_admin_ids).to eq([space_admin.id])

    relogin_as participant, scope: :user
    visit Decidim::EngineRouter.main_proxy(component).survey_path(survey)
    fill_in "What is your name?", with: "Jane"
    check "questionnaire_tos_agreement"

    perform_enqueued_jobs do
      accept_confirm { click_on "Submit" }
      expect(page).to have_content("Survey successfully responded.")
    end

    admin_emails = ActionMailer::Base.deliveries.select { |email| email.to.include?(space_admin.email) }
    expect(admin_emails.map(&:subject)).to include("New response to \"Follow up\"")
    expect(ActionMailer::Base.deliveries.flat_map(&:to)).not_to include(admin.email)

    relogin_as space_admin, scope: :user
    visit decidim.notifications_path

    expect(page).to have_link("Follow up", href: messages_path)
  end
end
