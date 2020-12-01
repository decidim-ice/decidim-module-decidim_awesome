# frozen_string_literal: true

require "spec_helper"

describe "Show proposals editor", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let!(:component) do
    create(:proposal_component,
           manifest: manifest,
           participatory_space: participatory_process)
  end

  let!(:proposal) { create(:proposal, body: content, component: component) }
  let(:content) { "<em>An awesome proposal</em>\n## An awesome title" }
  let(:proposal_title) { proposal.title.is_a?(Hash) ? translated(proposal.title) : proposal.title }

  let!(:user) { create :user, :confirmed, organization: organization }
  let(:rte_enabled) { false }
  let!(:use_markdown_editor) { create(:awesome_config, organization: organization, var: :use_markdown_editor, value: markdown_enabled) }
  let!(:constraint) { create(:config_constraint, awesome_config: use_markdown_editor, settings: { "participatory_space_manifest" => manifest_type }) }
  let(:manifest_type) { "participatory_processes" }
  let(:markdown_enabled) { false }

  before do
    organization.update(rich_text_editor_in_public_views: rte_enabled)
    login_as user, scope: :user
    visit_component

    click_link proposal_title
  end

  shared_examples "renders html" do
    it "do not sanitize" do
      expect(page).to have_selector("em", text: "An awesome proposal")
      expect(page).to have_content("## An awesome title")
      expect(page).not_to have_selector("h2", text: "An awesome title")
    end
  end

  shared_examples "renders text" do
    it "sanitizes" do
      expect(page).to have_content("An awesome proposal")
      expect(page).to have_content("## An awesome title")
      expect(page).not_to have_selector("em", text: "An awesome proposal")
      expect(page).not_to have_selector("h2", text: "An awesome title")
    end
  end

  shared_examples "renders markdown" do
    it "renderizes" do
      expect(page).to have_content("An awesome proposal")
      expect(page).not_to have_content("## An awesome title")
      expect(page).to have_selector("h2", text: "An awesome title")
    end
  end

  context "when rich text editor is enabled for participants" do
    let(:rte_enabled) { true }

    it_behaves_like "renders html"

    context "and markdown is enabled" do
      let(:markdown_enabled) { true }

      it_behaves_like "renders markdown"

      context "and constraint do not match current context" do
        let(:manifest_type) { "assemblies" }

        it_behaves_like "renders html"
      end
    end
  end

  context "when rich text editor is NOT enabled for participants" do
    it_behaves_like "renders text"

    context "and markdown is enabled" do
      let(:markdown_enabled) { true }

      it_behaves_like "renders markdown"

      context "and constraint do not match current context" do
        let(:manifest_type) { "assemblies" }

        it_behaves_like "renders text"
      end
    end
  end
end
