# frozen_string_literal: true

require "spec_helper"

describe "Custom proposals fields", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:participatory_process) { create(:participatory_process, :with_steps, organization: organization) }
  let!(:component) do
    create(:proposal_component,
           :with_creation_enabled,
           manifest: manifest,
           participatory_space: participatory_process)
  end
  let!(:config) { create(:awesome_config, organization: organization, var: :proposal_custom_fields, value: custom_fields) }
  let!(:private_config) { create(:awesome_config, organization: organization, var: :proposal_private_custom_fields, value: private_custom_fields) }
  let(:config_helper) { create(:awesome_config, organization: organization, var: :proposal_custom_field_bar) }
  let(:private_config_helper) { create(:awesome_config, organization: organization, var: :proposal_private_custom_field_baz) }
  let!(:constraint) { create(:config_constraint, awesome_config: config_helper, settings: { "participatory_space_manifest" => "participatory_processes", "participatory_space_slug" => slug }) }
  let!(:private_constraint) { create(:config_constraint, awesome_config: private_config_helper, settings: { "participatory_space_manifest" => "participatory_processes" }) }
  let(:slug) { participatory_process.slug }

  let(:data1) { '{"type":"text","label":"Full Name","subtype":"text","className":"form-control","name":"text-1476748004559"}' }
  let(:data2) { '{"type":"select","label":"Occupation","className":"form-control","name":"select-1476748006618","values":[{"label":"Street Sweeper","value":"option-1","selected":true},{"label":"Moth Man","value":"option-2"},{"label":"Chemist","value":"option-3"}]}' }
  let(:data3) { '{"type":"textarea","label":"Short Bio","rows":"5","className":"form-control","name":"textarea-1476748007461"}' }
  let(:private_data1) { '{"type":"text","label":"Phone Number","subtype":"text","className":"form-control","name":"text-1476748004579"}' }

  let(:custom_fields) do
    {
      "foo" => "[#{data1},#{data2}]",
      "bar" => "[#{data3}]"
    }
  end

  let(:private_custom_fields) do
    {
      "baz" => "[#{private_data1}]"
    }
  end

  before do
    login_as user, scope: :user
    visit_component

    click_link "New proposal"
  end

  it "displays custom fields & private fields" do
    expect(page).to have_content("Title")
    expect(page).not_to have_content("Body")
    expect(page).to have_content("Full Name")
    expect(page).to have_content("Occupation")
    expect(page).to have_content("Street Sweeper")
    expect(page).to have_content("Short Bio")
    expect(page).not_to have_css(".form-error.is-visible")
    expect(page).to have_content("This information won't be published")
    within "#proposal-custom-field-private_body" do
      expect(page).to have_content("Phone Number")
    end
  end

  context "when there are not custom fields" do
    let(:custom_fields) do
      {
        "bar" => "[#{data3}]"
      }
    end
    let(:slug) { "another-slug" }

    it "displays normal proposal editor and private fields" do
      expect(page).to have_content("Title")
      expect(page).to have_content("Body")
      expect(page).not_to have_content("Full Name")
      expect(page).not_to have_content("Occupation")
      expect(page).not_to have_content("Street Sweeper")
      expect(page).not_to have_content("Short Bio")
      expect(page).to have_content("This information won't be published")
      within "#proposal-custom-field-private_body" do
        expect(page).to have_content("Phone Number")
      end
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
      expect(page).to have_content("This information won't be published")
      within "#proposal-custom-field-private_body" do
        expect(page).to have_content("Phone Number")
      end
    end
  end

  context "when private fields are scoped to other places" do
    let!(:private_constraint) { create(:config_constraint, awesome_config: private_config_helper, settings: { "participatory_space_manifest" => "assemblies" }) }

    it "displays the scoped fields" do
      expect(page).to have_content("Title")
      expect(page).not_to have_content("Body")
      expect(page).to have_content("Full Name")
      expect(page).to have_content("Occupation")
      expect(page).to have_content("Street Sweeper")
      expect(page).to have_content("Short Bio")
      expect(page).not_to have_css(".form-error.is-visible")
      expect(page).not_to have_content("This information won't be published")
      expect(page).not_to have_css("#proposal-custom-field-private_body")
      expect(page).not_to have_content("Phone Number")
    end
  end

  context "when creating the proposal" do
    it "saves the proposal in XML" do
      fill_in :proposal_title, with: "A far west character"
      fill_in :"text-1476748004559", with: "Lucky Luke"
      fill_in :"textarea-1476748007461", with: "I shot everything"
      fill_in :"text-1476748004579", with: "123456789"

      click_button "Continue"
      sleep 1
      expect(page).to have_content("Full Name")
      expect(page).to have_xpath("//input[@class='form-control'][@id='text-1476748004559'][@user-data='Lucky Luke']")
      expect(page).to have_content("Occupation")
      expect(page).to have_content("Street Sweeper")
      expect(page).to have_content("Short Bio")
      expect(page).to have_content("Phone Number")
      expect(page).to have_xpath("//textarea[@class='form-control'][@id='textarea-1476748007461'][@user-data='I shot everything']")
      expect(page).not_to have_xpath("//textarea[@class='form-control'][@id='text-1476748004579'][@user-data='123456789']")
      expect(page).not_to have_css(".form-error.is-visible")
      expect(Decidim::Proposals::Proposal.last.body["en"]).to include('<dd id="text-1476748004559" name="text"><div>Lucky Luke</div>')
      expect(Decidim::Proposals::Proposal.last.body["en"]).to include('<dd id="textarea-1476748007461" name="textarea"><div>I shot everything</div></dd>')
      expect(Decidim::Proposals::Proposal.last.private_body).to include('<dd id="text-1476748004579" name="text"><div>123456789</div></dd>')
      click_on "Send"
      expect(page).to have_content("Publish your proposal")
      click_on "Publish"
      expect(page).to have_content("A far west character")
      expect(page).to have_content("Full Name")
      expect(page).to have_content("Lucky Luke")
      expect(page).to have_content("Occupation")
      expect(page).to have_content("Street Sweeper")
      expect(page).to have_content("Short Bio")
      expect(page).not_to have_content("Phone Number")
      expect(page).not_to have_content("123456789")
    end
  end
end
