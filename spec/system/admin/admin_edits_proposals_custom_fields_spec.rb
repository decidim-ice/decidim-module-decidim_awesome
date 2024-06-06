# frozen_string_literal: true

require "spec_helper"

describe "Admin edits proposals" do
  let(:manifest_name) { "proposals" }
  let(:organization) { participatory_process.organization }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:config) { create(:awesome_config, organization:, var: :proposal_custom_fields, value: custom_fields) }
  let(:config_helper) { create(:awesome_config, organization:, var: :proposal_custom_field_bar) }
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
  let!(:proposal) do
    create(:proposal,
           :official,
           component:,
           body: {
             en: '<xml><dl><dt>Bio</dt><dd id="textarea-1476748007461"><div>I shot the sheriff</div></dd></dl></xml>',
             ca: '<xml><dl><dt>Bio</dt><dd id="textarea-1476748007461"><div>Jo disparo al sheriff</div></dd></dl></xml>'
           })
  end

  include_context "when managing a component as an admin"

  before do
    visit_component_admin

    find("a.action-icon--edit-proposal").click
  end

  it "displays custom fields" do
    expect(page).to have_content("Title")
    expect(page).to have_no_content("Body")
    expect(page).to have_content("Full Name")
    expect(page).to have_content("Occupation")
    expect(page).to have_content("Street Sweeper")
    expect(page).to have_content("Short Bio")
    expect(page).to have_xpath("//textarea[@class='form-control'][@id='textarea-1476748007461'][@user-data='I shot the sheriff']")
    expect(page).to have_no_css(".form-error.is-visible")

    within "#proposal-body-tabs" do
      click_link_or_button "Català"

      expect(page).to have_xpath("//textarea[@class='form-control'][@id='textarea-1476748007461'][@user-data='Jo disparo al sheriff']")
    end
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
      expect(page).to have_no_content("Full Name")
      expect(page).to have_no_content("Occupation")
      expect(page).to have_no_content("Street Sweeper")
      expect(page).to have_no_content("Short Bio")
    end
  end

  context "and some are scoped to other places" do
    let(:slug) { "another-slug" }

    it "displays the scoped fields" do
      expect(page).to have_content("Title")
      expect(page).to have_no_content("Body")
      expect(page).to have_content("Full Name")
      expect(page).to have_content("Occupation")
      expect(page).to have_content("Street Sweeper")
      expect(page).to have_no_content("Short Bio")
      expect(page).to have_no_css(".form-error.is-visible")
    end
  end

  context "when creating the proposal" do
    it "saves the proposal in XML" do
      fill_in :proposal_title_en, with: "A far west character"
      fill_in :"text-1476748004559", with: "Lucky Luke"
      fill_in :"textarea-1476748007461", with: "I shot everything"

      click_link_or_button "Update"

      expect(Decidim::Proposals::Proposal.last.body["en"]).to include('<dd id="text-1476748004559" name="text"><div>Lucky Luke</div>')
      expect(Decidim::Proposals::Proposal.last.body["en"]).to include('<dd id="textarea-1476748007461" name="textarea"><div>I shot everything</div></dd>')
    end

    context "and has multiple languages" do
      it "saves the proposal in XML" do
        fill_in :proposal_title_en, with: "A far west character"
        fill_in :"text-1476748004559", with: "Lucky Luke"
        fill_in :"textarea-1476748007461", with: "I shot everything"

        within "#proposal-body-tabs" do
          click_link_or_button "Català"
        end

        fill_in :"text-1476748004559", with: "Lucky Luke"
        fill_in :"textarea-1476748007461", with: "Li agrada disparar"

        click_link_or_button "Update"

        expect(Decidim::Proposals::Proposal.last.body["en"]).to include('<dd id="text-1476748004559" name="text"><div>Lucky Luke</div>')
        expect(Decidim::Proposals::Proposal.last.body["en"]).to include('<dd id="textarea-1476748007461" name="textarea"><div>I shot everything</div></dd>')
        expect(Decidim::Proposals::Proposal.last.body["ca"]).to include('<dd id="textarea-1476748007461" name="textarea"><div>Li agrada disparar</div></dd>')
      end
    end
  end
end
