# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/box_label_editor"

describe "Admin manages custom proposal fields" do
  let(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:custom_fields) do
    {}
  end
  let!(:config) { create(:awesome_config, organization:, var: :proposal_custom_fields, value: custom_fields) }
  let(:config_helper) { create(:awesome_config, organization:, var: :proposal_custom_field_bar) }
  let!(:constraint) { create(:config_constraint, awesome_config: config_helper, settings: { "participatory_space_manifest" => "participatory_processes", component_manifest: "proposals" }) }
  let!(:another_constraint) { create(:config_constraint, awesome_config: config_helper, settings: { "participatory_space_manifest" => "participatory_processes" }) }

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
    it "saves the content" do
      click_link_or_button 'Add a new "custom fields" box'

      expect(page).to have_admin_callout("created successfully")

      sleep 2
      # page.execute_script("$('.proposal_custom_fields_editor:first')[0].FormBuilder.actions.setData(#{data})")
      page.execute_script("document.querySelector('.proposal_custom_fields_editor').FormBuilder.actions.setData(#{data})")

      click_link_or_button "Update configuration"

      sleep 2
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

    it "updates the content" do
      sleep 2
      expect(page).to have_content("Full Name")
      expect(page).to have_content("Occupation")
      expect(page).to have_content("Street Sweeper")
      expect(page).to have_no_content("Short Bio")

      page.execute_script("$('.proposal_custom_fields_container[data-key=\"foo\"] .proposal_custom_fields_editor')[0].FormBuilder.actions.setData(#{data})")
      click_link_or_button "Update configuration"

      sleep 2
      expect(page).to have_admin_callout("updated successfully")
      expect(page).to have_content("Full Name")
      expect(page).to have_no_content("Occupation")
      expect(page).to have_no_content("Street Sweeper")
      expect(page).to have_content("Short Bio")
    end

    it_behaves_like "edits box label inline", :fields, :foo

    context "when removing a box" do
      let(:custom_fields) do
        {
          "foo" => "[#{data1}]",
          "bar" => "[#{data2}]"
        }
      end

      it "updates the content" do
        sleep 2
        expect(page).to have_content("Full Name")
        expect(page).to have_content("Occupation")
        expect(page).to have_content("Street Sweeper")
        expect(page).to have_no_content("Short Bio")

        within ".proposal_custom_fields_container[data-key=\"foo\"]" do
          accept_confirm { click_link_or_button 'Remove this "custom fields" box' }
        end

        sleep 2
        expect(page).to have_admin_callout("removed successfully")
        expect(page).to have_no_content("Full Name")
        expect(page).to have_content("Occupation")
        expect(page).to have_content("Street Sweeper")
        expect(page).to have_no_content("Short Bio")

        expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: :proposal_custom_field_foo)).not_to be_present
        expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: :proposal_custom_field_bar)).to be_present
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
        within ".proposal_custom_fields_container[data-key=\"foo\"]" do
          click_link_or_button "Add case"
        end

        select "Processes", from: "constraint_participatory_space_manifest"
        within "#new-modal-proposal_custom_field_foo" do
          click_link_or_button "Save"
        end

        sleep 2

        within ".proposal_custom_fields_container[data-key=\"foo\"] .constraints-editor" do
          expect(page).to have_content("Processes")
        end

        expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: :proposal_custom_field_bar)).to be_present
        expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: :proposal_custom_field_bar).constraints.first.settings).to eq(constraint.settings)
      end

      context "when removing a constraint" do
        let(:custom_fields) do
          {
            "foo" => "[#{data1}]",
            "bar" => "[#{data2}]"
          }
        end

        it "removes the helper config var" do
          within ".proposal_custom_fields_container[data-key=\"bar\"] .constraints-editor" do
            expect(page).to have_content("Processes")
            expect(page).to have_content("Proposals")
          end

          within ".proposal_custom_fields_container[data-key=\"bar\"]" do
            within first(".constraints-list li") do
              click_link_or_button "Delete"
            end
          end

          within ".proposal_custom_fields_container[data-key=\"bar\"] .constraints-editor" do
            expect(page).to have_no_content("Proposals")
          end

          visit decidim_admin_decidim_awesome.config_path(:proposal_custom_fields)

          within ".proposal_custom_fields_container[data-key=\"bar\"] .constraints-editor" do
            expect(page).to have_no_content("Proposals")
          end

          expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: :proposal_custom_field_bar)).to be_present
          expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: :proposal_custom_field_bar).constraints.count).to eq(1)
          expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: :proposal_custom_field_bar).constraints.first).to eq(another_constraint)
        end

        context "and there is only one constraint" do
          let!(:another_constraint) { nil }

          it "do not remove the helper config var" do
            within ".proposal_custom_fields_container[data-key=\"bar\"]" do
              click_link_or_button "Delete"
            end

            within ".proposal_custom_fields_container[data-key=\"bar\"] .constraints-editor" do
              expect(page).to have_content("Proposals")
            end

            expect(page).to have_content("Sorry, this cannot be deleted")
            expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: :proposal_custom_field_bar).constraints.count).to eq(1)
            expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: :proposal_custom_field_bar).constraints.first).to eq(constraint)
          end
        end
      end
    end
  end
end
