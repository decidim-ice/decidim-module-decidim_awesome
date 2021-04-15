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
  let!(:proposal) { create :proposal, :with_amendments, users: [author], body: body, component: component }
  let(:author) { create :user, :confirmed, organization: organization }
  let!(:config) { create :awesome_config, organization: organization, var: :proposal_custom_fields, value: custom_fields }
  let(:config_helper) { create :awesome_config, organization: organization, var: :proposal_custom_field_foo }
  let!(:constraint) { create(:config_constraint, awesome_config: config_helper, settings: { "participatory_space_manifest" => "participatory_processes", "participatory_space_slug" => slug }) }
  let(:slug) { participatory_process.slug }
  let(:body) do
    { en: answer }
  end
  let(:answer) { '<xml><dl><dt>Bio</dt><dd id="textarea-1476748007461"><div>I shot the sheriff</div></dd></dl></xml>' }
  let(:data) { "[#{data1},#{data2},#{data3}]" }
  let(:data1) { '{"type":"text","label":"Full Name","subtype":"text","className":"form-control","name":"text-1476748004559"}' }
  let(:data2) { '{"type":"select","label":"Occupation","className":"form-control","name":"select-1476748006618","values":[{"label":"Street Sweeper","value":"option-1","selected":true},{"label":"Moth Man","value":"option-2"},{"label":"Chemist","value":"option-3"}]}' }
  let(:data3) { '{"type":"textarea","label":"Short Bio","rows":"5","className":"form-control","name":"textarea-1476748007461"}' }

  let(:custom_fields) do
    {
      "foo" => "[#{data1},#{data2},#{data3}]"
    }
  end

  before do
    organization.update(rich_text_editor_in_public_views: rte_enabled)
    login_as user, scope: :user
    visit_component
  end

  shared_examples "has custom fields" do
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
  end

  shared_examples "saves custom fields" do |title_field, button, xpath|
    it "saves the proposal in XML" do
      fill_in title_field, with: "A far west character"
      fill_in :"text-1476748004559", with: "Lucky Luke"
      fill_in :"textarea-1476748007461", with: "I shot everything"

      click_button button
      sleep 1
      expect(page).to have_content("Full Name")
      if xpath
        expect(page).to have_xpath("//input[@class='form-control'][@id='text-1476748004559'][@user-data='Lucky Luke']")
        expect(page).to have_xpath("//textarea[@class='form-control'][@id='textarea-1476748007461'][@user-data='I shot everything']")
      else
        expect(page).to have_selector("dd#text-1476748004559", text: "Lucky Luke")
        expect(page).to have_selector("dd#textarea-1476748007461", text: "I shot everything")
      end
      expect(page).to have_content("Occupation")
      expect(page).to have_content("Street Sweeper")
      expect(page).to have_content("Short Bio")
      expect(page).not_to have_css(".form-error.is-visible")
      expect(Decidim::Proposals::Proposal.last.body["en"]).to include('<dd id="text-1476748004559" name="text"><div>Lucky Luke</div>')
      expect(Decidim::Proposals::Proposal.last.body["en"]).to include('<dd id="textarea-1476748007461" name="textarea"><div>I shot everything</div></dd>')
    end
  end

  shared_examples "has default fields" do
    it "displays title and body" do
      expect(page).to have_content("Title")
      expect(page).to have_content("Body")
      expect(page).not_to have_content("Full Name")
      expect(page).not_to have_content("Occupation")
      expect(page).not_to have_content("Street Sweeper")
      expect(page).not_to have_content("Short Bio")
      expect(page).to have_content("I shot the sheriff")
      expect(page).not_to have_css(".form-error.is-visible")
    end
  end

  context "when editing the proposal" do
    let(:author) { user }

    before do
      click_link proposal.title["en"]
      click_link "Edit proposal"
    end

    it_behaves_like "has custom fields"
    it_behaves_like "saves custom fields", :proposal_title, "Send", false

    context "and RTE is enabled" do
      let(:rte_enabled) { true }

      it_behaves_like "has custom fields"
      it_behaves_like "saves custom fields", :proposal_title, "Send", false
    end

    context "and custom fields are out of scope" do
      let(:slug) { "another-slug" }

      it_behaves_like "has default fields"
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

    it_behaves_like "has custom fields"
    it_behaves_like "saves custom fields", :amendment_emendation_params_title, "Create", true

    context "and RTE is enabled" do
      let(:rte_enabled) { true }

      it_behaves_like "has custom fields"
      it_behaves_like "saves custom fields", :amendment_emendation_params_title, "Create", true
    end

    context "and custom fields are out of scope" do
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

    it_behaves_like "has default fields" do
      it "is amendment editor page" do
        expect(page).to have_content("CREATE AMENDMENT DRAFT")
      end
    end
  end

  # context "when collaborative drafts" do
  #   it_behaves_like "has custom fields" do
  #     before do
  #       click_link proposal.title["en"]
  #       click_link "Edit proposal"
  #     end
  #   end
  # end
end
