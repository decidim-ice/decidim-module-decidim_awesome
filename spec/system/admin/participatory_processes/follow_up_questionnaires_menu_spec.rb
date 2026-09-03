# frozen_string_literal: true

require "spec_helper"

describe "Follow-up questionnaires menu in the participatory process admin" do
  let(:organization) { create(:organization) }
  let(:component) { create(:component, manifest_name: "surveys", organization:) }
  let(:participatory_process) { component.participatory_space }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let!(:admin_role) { create(:participatory_process_user_role, user: admin, participatory_process:, role: "admin") }
  let!(:questionnaire) { create(:questionnaire) }
  let!(:survey) { create(:survey, component:, questionnaire:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  context "when a follow-up questionnaire is configured for the space" do
    let!(:follow_up_questionnaire) { Decidim::DecidimAwesome::FollowUpQuestionnaire.create!(decidim_questionnaire_id: questionnaire.id, name: { "en" => "Follow up" }) }

    before do
      visit decidim_admin_participatory_processes.edit_component_path(participatory_process, component)
    end

    it "shows the follow-up questionnaires menu item" do
      expect(page).to have_link(
        "Follow-up questionnaires",
        href: decidim_admin_decidim_awesome.follow_up_questionnaire_messages_path(follow_up_questionnaire.decidim_questionnaire_id)
      )
    end
  end

  context "when no follow-up questionnaire is configured for the space" do
    it "does not show the follow-up questionnaires menu item" do
      expect(page).to have_no_link("Follow-up questionnaires")
    end
  end

  describe ".follow_up_questionnaire_messages_allowed?" do
    let(:user) { create(:user, :confirmed, organization:) }

    it "returns false when the user has no role in the participatory process" do
      expect(
        Decidim::DecidimAwesome::Menu.follow_up_questionnaire_messages_allowed?(user, participatory_process)
      ).to be false
    end

    it "returns false when the space is not a participatory process" do
      other_space = create(:assembly, organization:)

      expect(
        Decidim::DecidimAwesome::Menu.follow_up_questionnaire_messages_allowed?(user, other_space)
      ).to be false
    end
  end
end
