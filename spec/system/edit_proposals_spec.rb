# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/editor_examples"

describe "Show proposals editor", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let!(:component) do
    create(:proposal_component,
           manifest: manifest,
           participatory_space: participatory_process)
  end

  let!(:proposal) { create(:proposal, users: [user], component: component) }
  let(:proposal_title) { proposal.title.is_a?(Hash) ? translated(proposal.title) : proposal.title }

  let!(:user) { create :user, :confirmed, organization: organization }
  let(:rte_enabled) { false }
  let!(:allow_images_in_proposals) { create(:awesome_config, organization: organization, var: :allow_images_in_proposals, value: images_in_proposals) }
  let!(:allow_images_in_small_editor) { create(:awesome_config, organization: organization, var: :allow_images_in_small_editor, value: images_editor) }
  let!(:use_markdown_editor) { create(:awesome_config, organization: organization, var: :use_markdown_editor, value: markdown_enabled) }
  let!(:allow_images_in_markdown_editor) { create(:awesome_config, organization: organization, var: :allow_images_in_markdown_editor, value: markdown_images) }
  let(:images_in_proposals) { false }
  let(:images_editor) { false }
  let(:markdown_enabled) { false }
  let(:markdown_images) { false }
  let(:editor_selector) { "#proposal_body" }

  before do
    organization.update(rich_text_editor_in_public_views: rte_enabled)
    login_as user, scope: :user
    visit_component

    click_link proposal_title
    click_link "Edit proposal"
  end

  context "when rich text editor is enabled for participants" do
    let(:rte_enabled) { true }

    it_behaves_like "has no drag and drop", true

    context "and images in RTE are enabled" do
      let(:images_editor) { true }

      it_behaves_like "has drag and drop", true
    end

    context "and markdown is enabled" do
      let(:markdown_enabled) { true }

      it_behaves_like "has markdown editor"

      context "and images are enabled" do
        let(:markdown_images) { true }

        it_behaves_like "has markdown editor", true
      end
    end
  end

  context "when rich text editor is NOT enabled for participants" do
    it_behaves_like "has no drag and drop"

    context "and images in proposals is enabled" do
      let(:images_in_proposals) { true }

      it_behaves_like "has drag and drop"
    end

    context "and markdown is enabled" do
      let(:markdown_enabled) { true }

      it_behaves_like "has no markdown editor"
    end
  end

  context "when editing in markdown mode" do
    let(:rte_enabled) { true }
    let(:markdown_enabled) { true }
    let(:text) { "# title\\n\\nParagraph\\nline 2" }
    let(:html) { "<h1 id=\"title\">title</h1><p>Paragraph<br>line 2</p>" }

    it "converts markdown to html before saving" do
      page.execute_script("$('input[name=\"faker-inscrybmde\"]:first')[0].InscrybMDE.value('#{text}')")

      click_button "Send"

      expect(page).not_to have_content("# title")
      expect(page).to have_selector("h1", text: "title")
      expect(page).to have_selector("p", text: "Paragraph\nline 2")
      expect(Decidim::Proposals::Proposal.last.body["en"].gsub(/[\n\r]/, "")).to eq(html)
    end
  end
end
