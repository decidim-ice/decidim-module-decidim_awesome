# frozen_string_literal: true

require "spec_helper"

describe "Admin edits votes by proposal status settings", :slow do
  let(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let!(:component) { create(:proposal_component, participatory_space: participatory_process) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_participatory_processes.edit_component_path(participatory_process, component)
  end

  context "when votes are not enabled on the step" do
    it "hides the status filter checkbox" do
      within "fieldset.step-settings-#{participatory_process.active_step.id}" do
        expect(page).to have_no_content("Restrict voting by proposal status")
        expect(page).to have_no_content("Allowed statuses for votes")
      end
    end
  end

  context "when votes are enabled on the step" do
    before do
      within "fieldset.step-settings-#{participatory_process.active_step.id}" do
        check "Votes enabled"
      end
    end

    it "shows the status filter checkbox unchecked by default" do
      within "fieldset.step-settings-#{participatory_process.active_step.id}" do
        expect(page).to have_field("Restrict voting by proposal status", checked: false)
      end
    end

    it "keeps the statuses multiselect hidden until the checkbox is checked" do
      within "fieldset.step-settings-#{participatory_process.active_step.id}" do
        expect(page).to have_no_content("Allowed statuses for votes")

        check "Restrict voting by proposal status"

        expect(page).to have_content("Allowed statuses for votes")
      end
    end

    it "lists all component statuses plus 'Not answered' as choices when the multiselect is shown" do
      within "fieldset.step-settings-#{participatory_process.active_step.id}" do
        check "Restrict voting by proposal status"

        expect(page).to have_select(
          "Allowed statuses for votes",
          with_options: ["Not answered", "Accepted", "Evaluating", "Rejected"]
        )
      end
    end
  end

  context "when saving the configuration" do
    before do
      within "fieldset.step-settings-#{participatory_process.active_step.id}" do
        check "Votes enabled"
        check "Restrict voting by proposal status"
        select "Accepted", from: "Allowed statuses for votes"
      end
      click_on "Update"
    end

    it "persists the chosen statuses as tokens" do
      expect(page).to have_admin_callout("successfully")
      step_id = participatory_process.active_step.id.to_s
      expect(component.reload.step_settings[step_id].awesome_votes_enabled_by_status).to be(true)
      expect(component.step_settings[step_id].awesome_votes_enabled_states).to include("accepted")
    end
  end

  context "when saving 'Not answered' as the allowed status" do
    before do
      within "fieldset.step-settings-#{participatory_process.active_step.id}" do
        check "Votes enabled"
        check "Restrict voting by proposal status"
        select "Not answered", from: "Allowed statuses for votes"
      end
      click_on "Update"
    end

    it "persists the not_answered token" do
      expect(page).to have_admin_callout("successfully")
      step_id = participatory_process.active_step.id.to_s
      expect(component.reload.step_settings[step_id].awesome_votes_enabled_states).to include("not_answered")
    end
  end
end
