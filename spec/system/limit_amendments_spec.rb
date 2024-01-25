# frozen_string_literal: true

require "spec_helper"

describe "Custom proposals fields", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let(:component) do
    create(:proposal_component,
           manifest: manifest,
           participatory_space: participatory_process, settings: settings, step_settings: step_settings)
  end
  let(:active_step_id) { participatory_process.active_step.id }
  let(:step_settings) { { active_step_id => { amendment_creation_enabled: amendment_creation_enabled } } }
  let(:settings) { { amendments_enabled: amendments_enabled, limit_pending_amendments: limit_pending_amendments } }
  let(:user) { create(:user, :confirmed, organization: component.organization) }

  let!(:proposal) { create :proposal, component: component }
  let!(:emendation) { create(:proposal, title: { en: "An emendation" }, component: component) }
  let!(:amendment) { create(:amendment, amendable: proposal, emendation: emendation, state: amendment_state) }

  let(:amendment_state) { "evaluating" }
  let(:limit_pending_amendments) { true }
  let(:amendments_enabled) { true }
  let(:amendment_creation_enabled) { true }

  before do
    login_as user, scope: :user
    visit_component
    click_link proposal.title["en"]
  end

  context "when there's pending amendments" do
    it "cannot create a new one" do
      expect(page).to have_content(proposal.title["en"])
      expect(page).to have_content(emendation.title["en"])
      click_link "Amend"

      expect(page).to have_content("Currently, there's another amendment being evaluated for this proposal.")
    end

    context "and is not limited" do
      let(:limit_pending_amendments) { false }

      it "can create a new one" do
        expect(page).to have_content(proposal.title["en"])
        expect(page).to have_content(emendation.title["en"])
        click_link "Amend"

        expect(page).not_to have_content("Currently, there's another amendment being evaluated for this proposal.")
        expect(page).not_to have_content(proposal.title["en"])
        expect(page).to have_content("CREATE AMENDMENT DRAFT")
      end
    end
  end
end
