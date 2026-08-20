# frozen_string_literal: true

require "spec_helper"

describe "Follow-up questionnaires menu in assemblies and conferences admin" do
  let(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let!(:questionnaire) { create(:questionnaire) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  context "when the space is an assembly" do
    let(:assembly) { create(:assembly, organization:) }
    let(:component) { create(:component, manifest_name: "surveys", participatory_space: assembly, organization:) }
    let!(:survey) { create(:survey, component:, questionnaire:) }
    let!(:follow_up_questionnaire) { Decidim::DecidimAwesome::FollowUpQuestionnaire.create!(decidim_questionnaire_id: questionnaire.id, name: { "en" => "Follow up" }) }

    it "shows the follow-up questionnaires menu item" do
      visit decidim_admin_assemblies.edit_component_path(assembly, component)

      expect(page).to have_link(
        "Follow-up questionnaires",
        href: decidim_admin_decidim_awesome.follow_up_questionnaire_messages_path(follow_up_questionnaire.decidim_questionnaire_id)
      )
    end
  end

  context "when the space is a conference" do
    let(:conference) { create(:conference, organization:) }
    let(:component) { create(:component, manifest_name: "surveys", participatory_space: conference, organization:) }
    let!(:survey) { create(:survey, component:, questionnaire:) }
    let!(:follow_up_questionnaire) { Decidim::DecidimAwesome::FollowUpQuestionnaire.create!(decidim_questionnaire_id: questionnaire.id, name: { "en" => "Follow up" }) }

    it "shows the follow-up questionnaires menu item" do
      visit decidim_admin_conferences.edit_component_path(conference, component)

      expect(page).to have_link(
        "Follow-up questionnaires",
        href: decidim_admin_decidim_awesome.follow_up_questionnaire_messages_path(follow_up_questionnaire.decidim_questionnaire_id)
      )
    end
  end
end
