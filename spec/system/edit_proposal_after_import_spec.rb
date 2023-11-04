# frozen_string_literal: true

require "spec_helper"

describe "Edit proposals after import", type: :system do
  include_context "with a component"
  let(:organization) { create :organization }
  let(:user) { create :user, :confirmed, organization: organization }
  let(:manifest_name) { "proposals" }
  let!(:component) { create(:proposal_component, manifest: manifest, participatory_space: participatory_process) }
  let!(:proposal) { create(:proposal, users: [user], component: component) }
  let(:proposal_title) { translated(proposal.title) }
  let!(:allow_to_edit_proposals_after_import) { create(:awesome_config, organization: organization, var: :allow_to_edit_proposals_after_import, value: edit_proposal) }
  let(:copied_component) { create(:proposal_component, manifest: manifest, participatory_space: participatory_process) }
  let!(:copied_proposal) { create :proposal, component: copied_component, users: [user] }

  context "when editing proposal after import is enabled" do
    let(:edit_proposal) { true }

    before do
      visit_proposal(user)
    end

    context "when constrains are not present" do
      it "allows editing the proposal" do
        click_link proposal_title
        expect(page).to have_content("EDIT PROPOSAL")
      end
    end

    context "when constrains are present" do
      let!(:constraint) { create(:config_constraint, awesome_config: allow_to_edit_proposals_after_import, settings: settings) }

      context "when participatory space is not the same" do
        let(:settings) do
          { "participatory_space_manifest" => "assemblies" }
        end

        it "does not allows editing the proposal" do
          click_link proposal_title
          expect(page).not_to have_content("EDIT PROPOSAL")
        end
      end

      context "when participatory space is the same" do
        let(:settings) do
          { "participatory_space_manifest" => "participatory_processes" }
        end

        it "allows editing the proposal" do
          click_link proposal_title
          expect(page).to have_content("EDIT PROPOSAL")
        end
      end
    end
  end

  context "when editing a proposal after import is disabled" do
    let(:edit_proposal) { false }

    before do
      visit_proposal(user)
    end

    it "does not allow editing the proposal" do
      click_link proposal_title
      expect(page).not_to have_content("EDIT PROPOSAL")
    end
  end

  context "when editing a proposal after import by another user" do
    let(:another_user) { create :user, :confirmed, organization: organization }
    let(:edit_proposal) { true }

    before do
      visit_proposal(another_user)
    end

    it "does not allow editing the proposal" do
      click_link proposal_title
      expect(page).not_to have_content("EDIT PROPOSAL")
    end
  end

  private

  def visit_proposal(user)
    login_as user, scope: :user
    copied_proposal.link_resources([proposal], "copied_from_component")
    visit_component
  end
end
