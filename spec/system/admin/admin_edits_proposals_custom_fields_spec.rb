# frozen_string_literal: true

require "spec_helper"

describe "Admin edits proposals", type: :system do
  let(:manifest_name) { "proposals" }
  let(:organization) { participatory_process.organization }
  let!(:user) { create :user, :admin, :confirmed, organization: organization }
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
  let!(:proposal) { create :proposal, :official, component: component, body: { en: '<xml><dl><dt>Bio</dt><dd id="textarea-1476748007461"><div>I shot the sheriff</div></dd></dl></xml>' } }

  include_context "when managing a component as an admin"

  before do
    visit_component_admin

    find("a.action-icon--edit-proposal").click
  end

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
