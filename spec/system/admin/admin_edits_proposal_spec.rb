# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/editor_examples"

describe "Admin edits proposals", type: :system do
  let(:manifest_name) { "proposals" }
  let(:organization) { participatory_process.organization }
  let!(:user) { create :user, :admin, :confirmed, organization: organization }
  let!(:proposal) { create :proposal, :official, component: component }
  let!(:allow_images_in_proposals) { create(:awesome_config, organization: organization, var: :allow_images_in_proposals, value: images_in_proposals) }
  let!(:allow_images_in_small_editor) { create(:awesome_config, organization: organization, var: :allow_images_in_full_editor, value: images_editor) }
  let!(:use_markdown_editor) { create(:awesome_config, organization: organization, var: :use_markdown_editor, value: markdown_enabled) }
  let!(:allow_images_in_markdown_editor) { create(:awesome_config, organization: organization, var: :allow_images_in_markdown_editor, value: markdown_images) }
  let(:images_in_proposals) { false }
  let(:images_editor) { false }
  let(:markdown_enabled) { false }
  let(:markdown_images) { false }
  let(:rte_enabled) { false }
  let(:editor_selector) { "#proposal_body_en" }

  let!(:config) { create :awesome_config, organization: organization, var: :proposal_custom_fields, value: custom_fields }
  let(:config_helper) { create :awesome_config, organization: organization, var: :proposal_custom_field_bar }
  let!(:constraint) { create(:config_constraint, awesome_config: config_helper, settings: { "participatory_space_manifest" => "participatory_processes", "participatory_space_slug" => slug }) }
  let(:slug) { participatory_process.slug }

  let(:data) { "[#{data1},#{data2},#{data3}]" }
  let(:data1) { '{"type":"text","label":"Full Name","subtype":"text","className":"form-control","name":"text-1476748004559"}' }
  let(:data2) { '{"type":"select","label":"Occupation","className":"form-control","name":"select-1476748006618","values":[{"label":"Street Sweeper","value":"option-1","selected":true},{"label":"Moth Man","value":"option-2"},{"label":"Chemist","value":"option-3"}]}' }
  let(:data3) { '{"type":"textarea","label":"Short Bio","rows":"5","className":"form-control","name":"textarea-1476748007461"}' }

  let(:custom_fields) do
    {
      "foo" => "[#{data1},#{data2}]",
      "bar" => "[#{data3}]"
    }
  end

  include_context "when managing a component as an admin"

  before do
    organization.update(rich_text_editor_in_public_views: rte_enabled)
    visit_component_admin

    find("a.action-icon--edit-proposal").click
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
    it_behaves_like "has no drag and drop", true

    context "and images in RTE are enabled" do
      let(:images_editor) { true }

      it_behaves_like "has drag and drop", true
    end

    context "and images in proposals is enabled" do
      let(:images_in_proposals) { true }

      it_behaves_like "has no drag and drop", true
    end

    context "and markdown is enabled" do
      let(:markdown_enabled) { true }

      it_behaves_like "has markdown editor"
    end
  end

  context "when editing in markdown mode" do
    let(:rte_enabled) { true }
    let(:markdown_enabled) { true }
    let(:text) { "# title\\n\\nParagraph\\nline 2" }
    let(:html) { "<h1 id=\"title\">title</h1><p>Paragraph<br>line 2</p>" }

    it "converts markdown to html before saving" do
      sleep 1
      page.execute_script("$('input[name=\"faker-inscrybmde\"]:first')[0].InscrybMDE.value('#{text}')")

      click_button "Update"

      expect(Decidim::Proposals::Proposal.last.body["en"].gsub(/[\n\r]/, "")).to eq(html)
    end
  end

  context "when editing custom fields" do
    let!(:proposal) { create :proposal, :official, component: component, body: { en: '<xml><dl><dt>Bio</dt><dd id="textarea-1476748007461"><div>I shot the sheriff</div></dd></dl></xml>' } }

    it "displays custom fields" do
      expect(page).to have_content("Title")
      expect(page).not_to have_content("Body")
      expect(page).to have_content("Full Name")
      expect(page).to have_content("Occupation")
      expect(page).to have_content("Street Sweeper")
      expect(page).to have_content("Short Bio")
      expect(page).to have_xpath("//textarea[@class='form-control'][@id='textarea-1476748007461'][@user-data='I shot the sheriff']")
      expect(page).not_to have_css(".form-error.is-visible")
    end

    context "and there are out of scope" do
      let(:custom_fields) do
        {
          "bar" => "[#{data3}]"
        }
      end
      let(:slug) { "another-slug" }

      it "displays normal proposal editor" do
        expect(page).to have_content("Title")
        expect(page).to have_content("Body")
        expect(page).not_to have_content("Full Name")
        expect(page).not_to have_content("Occupation")
        expect(page).not_to have_content("Street Sweeper")
        expect(page).not_to have_content("Short Bio")
      end
    end

    context "and some are scoped to other places" do
      let(:slug) { "another-slug" }

      it "displays the scoped fields" do
        expect(page).to have_content("Title")
        expect(page).not_to have_content("Body")
        expect(page).to have_content("Full Name")
        expect(page).to have_content("Occupation")
        expect(page).to have_content("Street Sweeper")
        expect(page).not_to have_content("Short Bio")
        expect(page).not_to have_css(".form-error.is-visible")
      end
    end

    context "when creating the proposal" do
      it "saves the proposal in XML" do
        fill_in :proposal_title_en, with: "A far west character"
        fill_in :"text-1476748004559", with: "Lucky Luke"
        fill_in :"textarea-1476748007461", with: "I shot everything"

        click_button "Update"

        expect(Decidim::Proposals::Proposal.last.body["en"]).to include('<dd id="text-1476748004559" name="text"><div>Lucky Luke</div>')
        expect(Decidim::Proposals::Proposal.last.body["en"]).to include('<dd id="textarea-1476748007461" name="textarea"><div>I shot everything</div></dd>')
      end
    end
  end
end
