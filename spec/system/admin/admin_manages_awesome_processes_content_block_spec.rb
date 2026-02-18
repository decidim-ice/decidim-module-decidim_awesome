# frozen_string_literal: true

require "spec_helper"

describe "Admin manages Awesome Processes content block" do
  let(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let!(:active_process) { create(:participatory_process, :active, :published, organization:) }
  let!(:process_group) { create(:participatory_process_group, organization:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  describe "adding the block" do
    before do
      visit decidim_admin.edit_organization_homepage_path
    end

    it "lists 'Awesome Processes' in the add content block dropdown" do
      click_link_or_button "Add content block"
      expect(page).to have_content("Awesome Processes")
    end

    it "can add the block" do
      click_link_or_button "Add content block"
      click_link_or_button "Awesome Processes"

      expect(page).to have_content("Content block successfully created")
    end
  end

  describe "editing block settings" do
    let!(:content_block) do
      create(:content_block, organization:, manifest_name: :awesome_processes, scope_name: :homepage, settings:)
    end
    let(:settings) { {} }

    before do
      visit decidim_admin.edit_organization_homepage_content_block_path(content_block)
    end

    it "displays the settings form with all fields" do
      expect(page).to have_content("Awesome Processes")
      expect(page).to have_field("content_block_settings_max_results")
      expect(page).to have_select("content_block_settings_process_type")
      expect(page).to have_select("content_block_settings_process_group_id")
      expect(page).to have_select("content_block_settings_selection_criteria")
    end

    it "saves and persists the title" do
      fill_in "content_block_settings_title_en", with: "My Custom Title"
      click_link_or_button "Update"

      visit decidim_admin.edit_organization_homepage_content_block_path(content_block)
      expect(page).to have_field("content_block_settings_title_en", with: "My Custom Title")
    end

    it "saves and persists max_results" do
      fill_in "content_block_settings_max_results", with: 3
      click_link_or_button "Update"

      visit decidim_admin.edit_organization_homepage_content_block_path(content_block)
      expect(page).to have_field("content_block_settings_max_results", with: "3")
    end

    it "saves and persists process_type selection" do
      select "Only processes", from: "content_block_settings_process_type"
      click_link_or_button "Update"

      visit decidim_admin.edit_organization_homepage_content_block_path(content_block)
      expect(page).to have_select("content_block_settings_process_type", selected: "Only processes")
    end

    it "saves and persists process_group selection" do
      select translated(process_group.title), from: "content_block_settings_process_group_id"
      click_link_or_button "Update"

      visit decidim_admin.edit_organization_homepage_content_block_path(content_block)
      expect(page).to have_select("content_block_settings_process_group_id", selected: translated(process_group.title))
    end

    it "saves and persists selection_criteria" do
      select "Manual", from: "content_block_settings_selection_criteria"
      click_link_or_button "Update"

      visit decidim_admin.edit_organization_homepage_content_block_path(content_block)
      expect(page).to have_select("content_block_settings_selection_criteria", selected: "Manual")
    end

    describe "dynamic form behavior" do
      it "hides processes multiselect when selection_criteria is 'Active'" do
        expect(page).to have_select("content_block_settings_selection_criteria", selected: "Active")
        within "form" do
          expect(page).to have_no_css("[data-awesome-processes-manual]", text: "Processes")
        end
      end

      it "shows processes multiselect when switching to 'Manual'" do
        select "Manual", from: "content_block_settings_selection_criteria"
        within "[data-awesome-processes-manual]" do
          expect(page).to have_content("Processes")
        end
      end

      it "hides multiselect again when switching back to 'Active'" do
        select "Manual", from: "content_block_settings_selection_criteria"
        within "[data-awesome-processes-manual]" do
          expect(page).to have_content("Processes")
        end

        select "Active", from: "content_block_settings_selection_criteria"
        within "form" do
          expect(page).to have_no_css("[data-awesome-processes-manual]", text: "Processes")
        end
      end

      it "shows mixed hint when process_type is 'All processes and groups mixed'" do
        expect(page).to have_select("content_block_settings_process_type", selected: "All processes and groups mixed")
        within "[data-awesome-processes-type]" do
          expect(page).to have_content("In mixed mode")
        end
      end

      it "hides mixed hint when switching to 'Only processes'" do
        select "Only processes", from: "content_block_settings_process_type"
        within "[data-awesome-processes-type]" do
          expect(page).to have_no_content("In mixed mode")
        end
      end

      it "hides mixed hint when switching to 'Only process groups'" do
        select "Only process groups", from: "content_block_settings_process_type"
        within "[data-awesome-processes-type]" do
          expect(page).to have_no_content("In mixed mode")
        end
      end

      it "shows mixed hint again when switching back to 'All'" do
        select "Only processes", from: "content_block_settings_process_type"
        within "[data-awesome-processes-type]" do
          expect(page).to have_no_content("In mixed mode")
        end

        select "All processes and groups mixed", from: "content_block_settings_process_type"
        within "[data-awesome-processes-type]" do
          expect(page).to have_content("In mixed mode")
        end
      end
    end

    describe "edge cases" do
      context "when no process groups exist" do
        before do
          Decidim::ParticipatoryProcessGroup.where(organization:).destroy_all
          visit decidim_admin.edit_organization_homepage_content_block_path(content_block)
        end

        it "shows only 'Any group' option in the process group select" do
          options = all("#content_block_settings_process_group_id option")
          expect(options.size).to eq(1)
          expect(options.first.text).to eq("Any group")
        end
      end

      context "when no published processes and no groups exist" do
        before do
          Decidim::ParticipatoryProcess.where(organization:).destroy_all
          Decidim::ParticipatoryProcessGroup.where(organization:).destroy_all
          visit decidim_admin.edit_organization_homepage_content_block_path(content_block)
        end

        it "has empty manual multiselect" do
          select "Manual", from: "content_block_settings_selection_criteria"
          options = all("[data-awesome-processes-manual] select option")
          expect(options).to be_empty
        end
      end
    end
  end
end
