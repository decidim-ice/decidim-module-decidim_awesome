# frozen_string_literal: true

require "spec_helper"

describe "Custom proposals fields", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let(:component) do
    create(:proposal_component,
           :with_creation_enabled,
           :with_amendments_enabled,
           manifest: manifest,
           participatory_space: participatory_process)
  end
  let(:rte_enabled) { false }
  let!(:proposal) { create(:proposal, :with_amendments, users: [author], body: body, component: component) }
  let(:author) { create(:user, :confirmed, organization: organization) }
  let!(:config) { create(:awesome_config, organization: organization, var: :proposal_custom_fields, value: custom_fields) }
  let!(:private_config) { create(:awesome_config, organization: organization, var: :proposal_private_custom_fields, value: private_custom_fields) }
  let(:config_helper) { create(:awesome_config, organization: organization, var: :proposal_custom_field_foo) }
  let(:private_config_helper) { create(:awesome_config, organization: organization, var: :proposal_private_custom_field_baz) }
  let!(:constraint) { create(:config_constraint, awesome_config: config_helper, settings: { "participatory_space_manifest" => "participatory_processes", "participatory_space_slug" => slug }) }
  let!(:private_constraint) { create(:config_constraint, awesome_config: config_helper, settings: { "participatory_space_manifest" => "participatory_processes" }) }
  let(:slug) { participatory_process.slug }
  let(:body) do
    { en: answer }
  end
  let(:answer) { '<xml><dl><dt>Occupation</dt><dd id="select-1476748006618"><div alt="option-2">Moth Man</div></dd><dt>Bio</dt><dd id="textarea-1476748007461"><div>I shot the sheriff</div></dd></dl></xml>' }
  let(:data1) { '{"type":"text","label":"Full Name","subtype":"text","className":"form-control","name":"text-1476748004559"}' }
  let(:data2) { '{"type":"select","label":"Occupation","className":"form-control","name":"select-1476748006618","values":[{"label":"Street Sweeper","value":"option-1","selected":true},{"label":"Moth Man","value":"option-2"},{"label":"Chemist","value":"option-3"}]}' }
  let(:data3) { '{"type":"textarea","label":"Short Bio","rows":"5","className":"form-control","name":"textarea-1476748007461"}' }
  let(:private_data1) { '{"type":"text","label":"Phone Number","subtype":"text","className":"form-control","name":"text-1476748004579"}' }
  let(:model) { proposal }
  let(:custom_fields) do
    {
      "foo" => "[#{data1},#{data2},#{data3}]"
    }
  end
  let(:private_custom_fields) do
    {
      "baz" => "[#{private_data1}]"
    }
  end

  before do
    organization.update(rich_text_editor_in_public_views: rte_enabled)
    login_as user, scope: :user
    visit_component
  end

  shared_examples "has custom fields" do |textarea|
    it "displays public and private" do
      expect(page).to have_content("Title")
      expect(page).not_to have_content("Body")
      expect(page).to have_content("Full Name")
      expect(page).to have_content("Occupation")
      expect(page).to have_content("Moth Man")
      expect(page).to have_xpath("//select[@class='form-control'][@id='select-1476748006618'][@user-data='option-2']")
      expect(page).to have_content("Short Bio")
      expect(page).to have_xpath(textarea)
      expect(page).not_to have_css(".form-error.is-visible")
      expect(page).to have_content("This information won't be published")
      within "#proposal-custom-field-private_body" do
        expect(page).to have_content("Phone Number")
      end
    end
  end

  shared_examples "saves custom fields" do |title_field, button, xpath|
    it "saves the proposal in XML" do
      fill_in title_field, with: "A far west character"
      fill_in :"text-1476748004559", with: "Lucky Luke"
      fill_in :"textarea-1476748007461", with: "I shot everything"
      fill_in :"text-1476748004579", with: "555-555-555"

      click_button button
      sleep 1
      expect(page).to have_content("Full Name")
      if xpath
        expect(page).to have_xpath("//input[@class='form-control'][@id='text-1476748004559'][@user-data='Lucky Luke']")
        expect(page).to have_xpath("//textarea[@class='form-control'][@id='textarea-1476748007461'][@user-data='I shot everything']")
        expect(page).to have_xpath("//input[@class='form-control'][@id='text-1476748004579'][@user-data='555-555-555']")
      else
        expect(page).to have_css("dd#text-1476748004559", text: "Lucky Luke")
        expect(page).to have_css("dd#textarea-1476748007461", text: "I shot everything")
        expect(page).not_to have_css("dd#text-1476748004579", text: "555-555-555")
        expect(page).not_to have_content("Phone Number")
        expect(model.reload.private_body).to include('<dd id="text-1476748004579" name="text"><div>555-555-555</div></dd>')
      end
      expect(page).to have_content("Occupation")
      expect(page).to have_content("Moth Man")
      expect(page).to have_content("Short Bio")
      expect(page).not_to have_css(".form-error.is-visible")
    end
  end

  shared_examples "has default fields" do
    it "displays title and body" do
      expect(page).to have_content("Title")
      expect(page).to have_content("Body")
      expect(page).not_to have_content("Full Name")
      expect(page).to have_content("Occupation")
      expect(page).to have_content("Moth Man")
      expect(page).not_to have_content("Short Bio")
      expect(page).to have_content("I shot the sheriff")
      expect(page).not_to have_css(".form-error.is-visible")
      expect(page).not_to have_content("This information won't be published")
      expect(page).not_to have_content("Phone Number")
    end
  end

  context "when editing the proposal" do
    let(:author) { user }

    before do
      click_link proposal.title["en"]
      click_link "Edit proposal"
    end

    it_behaves_like "has custom fields", "//textarea[@class='form-control'][@id='textarea-1476748007461'][@user-data='I shot the sheriff']"
    it_behaves_like "saves custom fields", :proposal_title, "Send", false

    context "and has i18n keys" do
      let(:data3) { '{"type":"textarea","label":"activemodel.attributes.user.nickname","rows":"5","className":"form-control","name":"textarea-1476748007461"}' }

      it "displays the translation" do
        expect(page).to have_content("Nickname")
        expect(page).not_to have_content("activemodel.attributes.user.nickname")
        expect(page).not_to have_content("Short Bio")
      end
    end

    context "and RTE is enabled" do
      let(:rte_enabled) { true }

      it_behaves_like "has custom fields", "//textarea[@class='form-control'][@id='textarea-1476748007461'][@user-data='I shot the sheriff']"
      it_behaves_like "saves custom fields", :proposal_title, "Send", false
    end

    context "and custom fields are out of scope" do
      let!(:private_constraint) { create(:config_constraint, awesome_config: private_config_helper, settings: { "participatory_space_manifest" => "assemblies" }) }
      let(:slug) { "another-slug" }

      it_behaves_like "has default fields"
    end

    context "and proposal has unformatted content" do
      let!(:private_constraint) { create(:config_constraint, awesome_config: private_config_helper, settings: { "participatory_space_manifest" => "assemblies" }) }
      let(:answer) { "I shot the Sheriff\\nbut not Deputy" }

      it "has custom fields with content in the first textarea" do
        expect(page).to have_content("Title")
        expect(page).not_to have_content("Body")
        expect(page).to have_content("Full Name")
        expect(page).to have_content("Occupation")
        expect(page).to have_content("Moth Man")
        expect(page).not_to have_xpath("//select[@class='form-control'][@id='select-1476748006618'][@user-data='option-2']")
        expect(page).to have_content("Short Bio")
        expect(page).to have_xpath("//textarea[@class='form-control'][@id='textarea-1476748007461'][@user-data='I shot the Sheriff\\nbut not Deputy']")
        expect(page).to have_css(".form-error.is-visible")
        expect(page).not_to have_content("This information won't be published")
        expect(page).not_to have_content("Phone Number")
      end
    end

    context "and there a RicheText Editor type field" do
      let(:data3) { '{"type":"textarea","subtype":"richtext","label":"Short Bio","rows":"5","className":"form-control","name":"textarea-1476748007461"}' }

      it "has custom fields with richttext editor" do
        expect(page).to have_content("Full Name")
        expect(page).to have_xpath("//input[@id='textarea-1476748007461-input'][contains(@value, 'I shot the sheriff')]", visible: :hidden)
        expect(page).to have_content("Occupation")
        expect(page).to have_content("Moth Man")
        expect(page).to have_content("Short Bio")
        expect(page).not_to have_css(".form-error.is-visible")
        expect(page).to have_content("This information won't be published")
        expect(page).to have_content("Phone Number")
      end
    end
  end

  context "when amending the proposal" do
    before do
      click_link proposal.title["en"]
      click_link "Amend Proposal"
    end

    it "is amendment editor page" do
      expect(page).to have_content("CREATE AMENDMENT DRAFT")
    end

    it_behaves_like "has custom fields", "//textarea[@class='form-control'][@id='textarea-1476748007461'][@user-data='I shot the sheriff']"
    it_behaves_like "saves custom fields", :amendment_emendation_params_title, "Create", true

    context "and RTE is enabled" do
      let(:rte_enabled) { true }

      it_behaves_like "has custom fields", "//textarea[@class='form-control'][@id='textarea-1476748007461'][@user-data='I shot the sheriff']"
      it_behaves_like "saves custom fields", :amendment_emendation_params_title, "Create", true
    end

    context "and custom fields are out of scope" do
      let!(:private_constraint) { create(:config_constraint, awesome_config: private_config_helper, settings: { "participatory_space_manifest" => "assemblies" }) }
      let(:slug) { "another-slug" }

      it_behaves_like "has default fields"
    end
  end

  context "when participatory texts" do
    let!(:participatory_text) { create :participatory_text, component: component }
    let(:component) do
      create(:proposal_component,
             :with_creation_enabled,
             :with_amendments_and_participatory_texts_enabled,
             manifest: manifest,
             participatory_space: participatory_process)
    end

    before do
      click_link proposal.title["en"]
      click_link "Amend Proposal"
    end

    it "is amendment editor page" do
      expect(page).to have_content("CREATE AMENDMENT DRAFT")
    end

    it_behaves_like "has default fields"
  end

  context "when editing collaborative drafts" do
    let(:component) do
      create(:proposal_component,
             :with_creation_enabled,
             :with_collaborative_drafts_enabled,
             manifest: manifest,
             participatory_space: participatory_process)
    end
    let!(:collaborative_draft) { create :collaborative_draft, users: [author, user], body: answer, component: component }
    let(:model) { collaborative_draft }

    before do
      click_link "Access collaborative drafts"
      click_link collaborative_draft.title
      click_link "Edit collaborative draft"
    end

    it_behaves_like "has custom fields", "//textarea[@class='form-control'][@id='textarea-1476748007461'][@user-data='I shot the sheriff']"
    it_behaves_like "saves custom fields", :collaborative_draft_title, "Send", false
  end
end
