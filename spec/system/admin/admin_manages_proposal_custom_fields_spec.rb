# frozen_string_literal: true

require "spec_helper"

describe "Admin manages custom proposal fields", type: :system do
  let(:organization) { create :organization }
  let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }
  let(:custom_fields) do
    {}
  end
  let!(:config) { create :awesome_config, organization: organization, var: :proposal_custom_fields, value: custom_fields }
  let(:config_helper) { create :awesome_config, organization: organization, var: :proposal_custom_field_bar }
  let!(:constraint) { create(:config_constraint, awesome_config: config_helper, settings: { "participatory_space_manifest" => "participatory_processes" }) }

  let(:data) { "[#{data1},#{data2},#{data3}]" }
  let(:data1) { '{"type":"text","label":"Full Name","subtype":"text","className":"form-control","name":"text-1476748004559"}' }
  let(:data2) { '{"type":"select","label":"Occupation","className":"form-control","name":"select-1476748006618","values":[{"label":"Street Sweeper","value":"option-1","selected":true},{"label":"Moth Man","value":"option-2"},{"label":"Chemist","value":"option-3"}]}' }
  let(:data3) { '{"type":"textarea","label":"Short Bio","rows":"5","className":"form-control","name":"textarea-1476748007461"}' }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_decidim_awesome.config_path(:proposal_custom_fields)
  end

  context "when creating a new box" do
    it "saves the content in the hash" do
      click_link 'Add a new "custom fields" box'

      expect(page).to have_admin_callout("created successfully")

      sleep 1
      page.execute_script("$('.proposal-custom-field-editor:first')[0].FormBuilder.actions.setData(#{data})")

      find("*[type=submit]").click

      expect(page).to have_admin_callout("updated successfully")
      expect(page).to have_content("Full Name")
      expect(page).to have_content("Occupation")
      expect(page).to have_content("Street Sweeper")
      expect(page).to have_content("Short Bio")
    end
  end

  context "when updating new box" do
    let(:data) { "[#{data1},#{data3}]" }
    let(:custom_fields) do
      {
        "foo" => "[#{data1},#{data2}]",
        "bar" => "[]"
      }
    end

    it "updates the content in the hash" do
      expect(page).to have_content("Full Name")
      expect(page).to have_content("Occupation")
      expect(page).to have_content("Street Sweeper")
      expect(page).not_to have_content("Short Bio")

      sleep 1
      page.execute_script("$('#proposal-custom-field-editor-foo')[0].FormBuilder.actions.setData(#{data})")
      find("*[type=submit]").click

      expect(page).to have_admin_callout("updated successfully")
      expect(page).to have_content("Full Name")
      expect(page).not_to have_content("Occupation")
      expect(page).not_to have_content("Street Sweeper")
      expect(page).to have_content("Short Bio")
    end

    context "when removing a box" do
      let(:custom_fields) do
        {
          "foo" => "[#{data1}]",
          "bar" => "[#{data2}]"
        }
      end

      it "updates the content in the hash" do
        expect(page).to have_content("Full Name")
        expect(page).to have_content("Occupation")
        expect(page).to have_content("Street Sweeper")
        expect(page).not_to have_content("Short Bio")

        within ".proposal-custom-field[data-key=\"foo\"]" do
          accept_confirm { click_link 'Remove this "custom fields" box' }
        end

        expect(page).to have_admin_callout("removed successfully")
        expect(page).not_to have_content("Full Name")
        expect(page).to have_content("Occupation")
        expect(page).to have_content("Street Sweeper")
        expect(page).not_to have_content("Short Bio")

        expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: organization, var: :proposal_custom_field_foo)).not_to be_present
        expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: organization, var: :proposal_custom_field_bar)).to be_present
      end
    end

    context "when adding a constraint" do
      let(:custom_fields) do
        {
          "foo" => "[#{data1}]",
          "bar" => "[#{data2}]"
        }
      end

      it "adds a new config helper var" do
        within ".proposal-custom-field[data-key=\"foo\"]" do
          click_link "Add case"
        end

        select "Processes", from: "constraint_participatory_space_manifest"
        within ".modal-content" do
          find("*[type=submit]").click
        end

        sleep 2

        within ".proposal-custom-field[data-key=\"foo\"] .constraints-editor" do
          expect(page).to have_content("Processes")
        end

        expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: organization, var: :proposal_custom_field_bar)).to be_present
        expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: organization, var: :proposal_custom_field_bar).constraints.first.settings).to eq("participatory_space_manifest" => "participatory_processes")
      end

      context "when removing a constraint" do
        let(:custom_fields) do
          {
            "foo" => "[#{data1}]",
            "bar" => "[#{data2}]"
          }
        end

        it "removes the helper config var" do
          within ".proposal-custom-field[data-key=\"bar\"] .constraints-editor" do
            expect(page).to have_content("Processes")
          end

          within ".proposal-custom-field[data-key=\"bar\"]" do
            click_link "Delete"
          end

          within ".proposal-custom-field[data-key=\"bar\"] .constraints-editor" do
            expect(page).not_to have_content("Processes")
          end

          visit decidim_admin_decidim_awesome.config_path(:proposal_custom_fields)

          within ".proposal-custom-field[data-key=\"bar\"] .constraints-editor" do
            expect(page).not_to have_content("Processes")
          end

          expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: organization, var: :proposal_custom_field_bar)).to be_present
          expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: organization, var: :proposal_custom_field_bar).constraints).not_to be_present
        end
      end
    end
  end
end
