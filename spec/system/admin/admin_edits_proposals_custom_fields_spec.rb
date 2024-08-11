# frozen_string_literal: true

require "spec_helper"

describe "Admin edits proposals", type: :system do
  let(:manifest_name) { "proposals" }
  let(:organization) { participatory_process.organization }
  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }
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

  let!(:proposal) do
    create(:proposal,
           :official,
           component: component,
           body: {
             en: '<xml><dl><dt>Bio</dt><dd id="textarea-1476748007461"><div>I shot the sheriff</div></dd></dl></xml>',
             ca: '<xml><dl><dt>Bio</dt><dd id="textarea-1476748007461"><div>Jo disparo al sheriff</div></dd></dl></xml>'
           })
  end

  include_context "when managing a component as an admin"

  before do
    visit_component_admin

    proposal.update_private_body!('<xml><dl><dt>Phone Number</dt><dd id="text-1476748004579"><div>555-555-555</div></dd></dl></xml>')
  end

  context "when editing the proposal" do
    before do
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
      expect(page).to have_content("This information won't be published")
      within "#proposal-custom-field-private_body" do
        expect(page).to have_content("Phone Number")
        expect(page).to have_xpath("//input[@class='form-control'][@id='text-1476748004579'][@user-data='555-555-555']")
      end

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

  context "when answering the proposal" do
    it "displays custom fields" do
      find("a.action-icon--show-proposal").click
      expect(page).to have_content("Bio")
      within "#textarea-1476748007461" do
        expect(page).to have_content("I shot the sheriff")
      end
      click_link_or_button "Private body"
      expect(page).to have_content("Phone Number")
      within "#text-1476748004579" do
        expect(page).to have_content("555-555-555")
      end
      expect(page).to have_content("This data was last updated less than a minute ago.")
      expect(page).not_to have_content("You might want to remove it")
    end

    context "when private data is required to be removed" do
      before do
        # rubocop:disable Rails/SkipsModelValidations
        proposal.extra_fields.update_column(:private_body_updated_at, 4.months.ago)
        # rubocop:enable Rails/SkipsModelValidations
        find("a.action-icon--show-proposal").click
      end

      it "displays a warning" do
        click_link_or_button "Private body"
        expect(page).to have_content("Phone Number")
        expect(page).to have_content("This data was last updated 4 months ago.")
        expect(page).to have_content("You might want to remove it")
      end
    end

    context "when private data is removed" do
      before do
        proposal.extra_fields.update(private_body: nil)
        find("a.action-icon--show-proposal").click
      end

      it "shows destroyed date" do
        click_link_or_button "Private body"
        expect(page).not_to have_content("Phone Number")
        expect(page).to have_content("This data was destroyed less than a minute ago.")
        expect(page).not_to have_content("555-555-555")
        expect(page).not_to have_content("You might want to remove it")
      end
    end

    context "when no private data, nor private data last update is present" do
      before do
        # rubocop:disable Rails/SkipsModelValidations
        proposal.extra_fields.update_column(:private_body, nil)
        proposal.extra_fields.update_column(:private_body_updated_at, nil)
        # rubocop:enable Rails/SkipsModelValidations
        find("a.action-icon--show-proposal").click
      end

      it "does not display the private data" do
        click_link_or_button "Private body"
        expect(page).not_to have_content("Phone Number")
        expect(page).not_to have_content("This data was last updated")
        expect(page).not_to have_content("This data was last destroyed")
        expect(page).not_to have_content("You might want to remove it")
      end
    end

    context "when private fields are scoped to other places" do
      let!(:private_constraint) { create(:config_constraint, awesome_config: private_config_helper, settings: { "participatory_space_manifest" => "assemblies" }) }

      it "does not display private custom fields" do
        find("a.action-icon--show-proposal").click
        expect(page).to have_content("Bio")
        within "#textarea-1476748007461" do
          expect(page).to have_content("I shot the sheriff")
        end
        expect(page).not_to have_content("Private body")
        expect(page).not_to have_content("Phone Number")
        expect(page).not_to have_content("555-555-555")
      end
    end
  end
end
