# frozen_string_literal: true

require "spec_helper"

describe "Custom proposals fields" do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let(:component) do
    create(:proposal_component,
           :with_creation_enabled,
           :with_amendments_enabled,
           manifest:,
           participatory_space: participatory_process)
  end
  let(:rte_enabled) { false }
  let!(:proposal) { create(:proposal, :with_amendments, users: [author], body:, component:) }
  let(:author) { create(:user, :confirmed, organization:) }
  let!(:config) { create(:awesome_config, organization:, var: :proposal_custom_fields, value: custom_fields) }
  let!(:private_config) { create(:awesome_config, organization:, var: :proposal_private_custom_fields, value: private_custom_fields) }
  let(:config_helper) { create(:awesome_config, organization:, var: :proposal_custom_field_foo) }
  let(:private_config_helper) { create(:awesome_config, organization:, var: :proposal_private_custom_field_baz) }
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
      expect(page).to have_no_content("Body")
      expect(page).to have_content("Full Name")
      expect(page).to have_content("Occupation")
      expect(page).to have_content("Moth Man")
      expect(page).to have_xpath("//select[@class='form-control'][@id='select-1476748006618'][@user-data='option-2']")
      expect(page).to have_content("Short Bio")
      expect(page).to have_xpath(textarea)
      expect(page).to have_no_css(".form-error.is-visible")
      expect(page).to have_content("This information won't be published")
      within "#proposal-custom-field-private_body" do
        expect(page).to have_content("Phone Number")
      end
    end
  end

  shared_examples "saves custom fields" do |title_field, button, amended = false|
    it "saves the proposal in XML" do
      fill_in title_field, with: "A far west character"
      fill_in :"text-1476748004559", with: "Lucky Luke"
      fill_in :"textarea-1476748007461", with: "I shot everything"
      fill_in :"text-1476748004579", with: "555-555-555"

      click_on button
      sleep 1
      # Preview
      expect(page).to have_content("Full Name")
      expect(page).to have_content("Lucky Luke")
      expect(page).to have_content("Occupation")
      expect(page).to have_content("Moth Man")
      expect(page).to have_content("Short Bio")
      expect(page).to have_content("I shot everything")
      expect(page).to have_no_content("Phone Number") # private field
      expect(page).to have_no_content("555-555-555")

      if amended
        expect(Decidim::Proposals::Proposal.last.body["en"]).to include("I shot everything")
        expect(Decidim::Proposals::Proposal.last.private_body).to include('<dd id="text-1476748004579" name="text"><div>555-555-555</div></dd>')
      else
        expect(model.reload.private_body).to include('<dd id="text-1476748004579" name="text"><div>555-555-555</div></dd>')
      end
    end
  end

  shared_examples "has default fields" do
    it "displays title and body" do
      expect(page).to have_content("Title")
      expect(page).to have_content("Body")
      expect(page).to have_no_content("Full Name")
      expect(page).to have_content("Occupation")
      expect(page).to have_content("Moth Man")
      expect(page).to have_no_content("Short Bio")
      expect(page).to have_content("I shot the sheriff")
      expect(page).to have_no_css(".form-error.is-visible")
      expect(page).to have_no_content("This information won't be published")
      expect(page).to have_no_content("Phone Number")
    end
  end

  context "when editing the proposal" do
    let(:author) { user }

    before do
      click_link_or_button proposal.title["en"]
      find("#dropdown-trigger-resource-#{proposal.id}").click
      click_on "Edit"
    end

    it_behaves_like "has custom fields", "//textarea[@class='form-control'][@id='textarea-1476748007461'][@user-data='I shot the sheriff']"
    it_behaves_like "saves custom fields", :proposal_title, "Send"

    context "and has i18n keys" do
      let(:data3) { '{"type":"textarea","label":"activemodel.attributes.user.nickname","rows":"5","className":"form-control","name":"textarea-1476748007461"}' }

      it "displays the translation" do
        expect(page).to have_content("Nickname")
        expect(page).to have_no_content("activemodel.attributes.user.nickname")
        expect(page).to have_no_content("Short Bio")
      end
    end

    context "and RTE is enabled" do
      let(:rte_enabled) { true }

      it_behaves_like "has custom fields", "//textarea[@class='form-control'][@id='textarea-1476748007461'][@user-data='I shot the sheriff']"
      it_behaves_like "saves custom fields", :proposal_title, "Send"
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
        expect(page).to have_no_content("Body")
        expect(page).to have_content("Full Name")
        expect(page).to have_content("Occupation")
        expect(page).to have_content("Moth Man")
        expect(page).to have_no_xpath("//select[@class='form-control'][@id='select-1476748006618'][@user-data='option-2']")
        expect(page).to have_content("Short Bio")
        expect(page).to have_xpath("//textarea[@class='form-control'][@id='textarea-1476748007461'][@user-data='I shot the Sheriff\\nbut not Deputy']")
        expect(page).to have_css(".form-error.is-visible")
        expect(page).to have_no_content("This information won't be published")
        expect(page).to have_no_content("Phone Number")
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
        expect(page).to have_no_css(".form-error.is-visible")
        expect(page).to have_content("This information won't be published")
        expect(page).to have_content("Phone Number")
      end
    end
  end

  context "when amending the proposal" do
    before do
      click_link_or_button proposal.title["en"]
      find("#dropdown-trigger-resource-#{proposal.id}").click
      find("a#amend-button").click
    end

    it "is amendment editor page" do
      expect(page).to have_content("Create Amendment Draft")
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

  context "when editing collaborative drafts" do
    let(:component) do
      create(:proposal_component,
             :with_creation_enabled,
             :with_collaborative_drafts_enabled,
             manifest:,
             participatory_space: participatory_process)
    end
    let!(:collaborative_draft) { create(:collaborative_draft, users: [author, user], body: answer, component:) }
    let(:model) { collaborative_draft }

    before do
      click_link_or_button "Access collaborative drafts"
      click_link_or_button collaborative_draft.title
      find("#dropdown-trigger-resource-#{collaborative_draft.id}").click
      click_on "Edit"
    end

    it_behaves_like "has custom fields", "//textarea[@class='form-control'][@id='textarea-1476748007461'][@user-data='I shot the sheriff']"
    it_behaves_like "saves custom fields", :collaborative_draft_title, "Send", false
  end
end
