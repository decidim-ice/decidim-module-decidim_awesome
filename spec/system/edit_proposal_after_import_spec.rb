# frozen_string_literal: true

require "spec_helper"

describe "Edit proposals after import", type: :system do
  include_context "with a component"
  let(:organization) { create :organization }
  let(:user) { create :user, :confirmed, organization: organization }
  let(:manifest_name) { "proposals" }
  let!(:proposal) { create(:proposal, users: [user], component: component) }
  let(:proposal_title) { translated(proposal.title) }
  let!(:assembly) { create(:assembly, organization: organization) }
  let!(:assembly_proposal_component) { create :component, participatory_space: assembly, manifest: manifest }
  let!(:assembly_proposal) { create(:proposal, :published, :official, component: assembly_proposal_component, users: [user]) }
  let!(:allow_to_edit_proposals_after_import) { create(:awesome_config, organization: organization, var: :allow_to_edit_proposals_after_import, value: edit_proposal) }
  let(:edit_proposal) { true }

  context "when editing proposal after import is enabled" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      assembly_proposal.coauthorships.first.update!(author: user)
      visit decidim_assemblies.decidim_assembly_proposals_path(assembly_slug: assembly.slug, component_id: assembly_proposal_component.id)
    end

    context "when constrains are not present" do
      it "allows editing the proposal" do
        click_link assembly_proposal.title["en"]
        expect(page).to have_content("EDIT PROPOSAL")
      end
    end

    context "when constrains are present" do
      let!(:constraint) { create(:config_constraint, awesome_config: allow_to_edit_proposals_after_import, settings: settings) }
      let(:settings) do
        { "participatory_space_manifest" => "participatory_processes" }
      end

      context "when participatory space is not the same" do
        it "does not allows editing the proposal" do
          puts "allow_to_edit_proposals_after_import #{allow_to_edit_proposals_after_import.inspect}"
          puts "allow_to_edit_proposals_after_import.constraints #{allow_to_edit_proposals_after_import.constraints.inspect}"
          click_link assembly_proposal.title["en"]
          expect(page).not_to have_content("EDIT PROPOSAL")
        end
      end

      context "when participatory space is the same" do
        before do
          visit_component
          click_link proposal_title
        end

        it "allows editing the proposal" do
          expect(page).to have_content("EDIT PROPOSAL")
        end
      end
    end
  end
end
