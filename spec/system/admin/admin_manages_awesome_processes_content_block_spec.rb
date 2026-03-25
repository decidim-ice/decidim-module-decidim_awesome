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
      expect(page).to have_select("content_block_settings_process_status")
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

    it "saves and persists process_status selection" do
      select "Only past processes", from: "content_block_settings_process_status"
      click_link_or_button "Update"

      visit decidim_admin.edit_organization_homepage_content_block_path(content_block)
      expect(page).to have_select("content_block_settings_process_status", selected: "Only past processes")
    end

    it "saves and persists selection_criteria" do
      select "Manual", from: "content_block_settings_selection_criteria"
      click_link_or_button "Update"

      visit decidim_admin.edit_organization_homepage_content_block_path(content_block)
      expect(page).to have_select("content_block_settings_selection_criteria", selected: "Manual")
    end

    describe "dynamic form behavior" do
      it "hides processes multiselect when selection_criteria is 'Automatic'" do
        expect(page).to have_select("content_block_settings_selection_criteria", selected: "Automatic")
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

      it "hides multiselect again when switching back to 'Automatic'" do
        select "Manual", from: "content_block_settings_selection_criteria"
        within "[data-awesome-processes-manual]" do
          expect(page).to have_content("Processes")
        end

        select "Automatic", from: "content_block_settings_selection_criteria"
        within "form" do
          expect(page).to have_no_css("[data-awesome-processes-manual]", text: "Processes")
        end
      end

      it "shows mixed hint when process_type is 'All processes'" do
        expect(page).to have_select("content_block_settings_process_type", selected: "All processes")
        within "[data-awesome-processes-type]" do
          expect(page).to have_content("Shows all processes sorted")
        end
      end

      it "hides mixed hint when switching to 'Only processes'" do
        select "Only processes", from: "content_block_settings_process_type"
        within "[data-awesome-processes-type]" do
          expect(page).to have_no_content("Shows all processes sorted")
        end
      end

      it "hides group filter when switching to 'Only processes'" do
        expect(page).to have_select("content_block_settings_process_group_id")
        select "Only processes", from: "content_block_settings_process_type"
        expect(page).to have_no_select("content_block_settings_process_group_id", visible: :visible)
      end

      it "shows group filter when switching back to 'All processes'" do
        select "Only processes", from: "content_block_settings_process_type"
        select "All processes", from: "content_block_settings_process_type"
        expect(page).to have_select("content_block_settings_process_group_id")
      end
    end

    describe "manual selection filtering" do
      let!(:group_a) { create(:participatory_process_group, organization:, title: { "en" => "Group Alpha" }) }
      let!(:process_in_group) { create(:participatory_process, :active, :published, organization:, participatory_process_group: group_a, title: { "en" => "Process In Alpha" }) }
      let!(:process_outside_group) { create(:participatory_process, :active, :published, organization:, title: { "en" => "Process Outside" }) }
      let!(:past_grouped_process) { create(:participatory_process, :past, :published, organization:, participatory_process_group: group_a, title: { "en" => "Past In Alpha" }) }

      before do
        # Revisit page so newly created groups/processes appear in the form
        visit decidim_admin.edit_organization_homepage_content_block_path(content_block)
        select "Manual", from: "content_block_settings_selection_criteria"
      end

      def open_tom_select
        find("[data-awesome-processes-manual] .ts-control input").click
      end

      it "filters processes by group when a group is selected" do
        select "Group Alpha", from: "content_block_settings_process_group_id"
        open_tom_select

        within ".ts-dropdown" do
          expect(page).to have_content("Process In Alpha")
          expect(page).to have_no_content("Process Outside")
        end
      end

      it "shows all processes when 'Any group' is selected" do
        select "All processes", from: "content_block_settings_process_status"
        select "Any group", from: "content_block_settings_process_group_id"
        open_tom_select

        within ".ts-dropdown" do
          expect(page).to have_content("Process In Alpha")
          expect(page).to have_content("Process Outside")
        end
      end

      it "filters processes by status" do
        select "Group Alpha", from: "content_block_settings_process_group_id"
        select "All processes", from: "content_block_settings_process_status"
        open_tom_select

        within ".ts-dropdown" do
          expect(page).to have_content("Process In Alpha")
          expect(page).to have_content("Past In Alpha")
        end
      end

      it "filters by process type" do
        select "All processes", from: "content_block_settings_process_status"
        select "Only processes", from: "content_block_settings_process_type"
        open_tom_select

        within ".ts-dropdown" do
          expect(page).to have_content("Process Outside")
          expect(page).to have_no_content("Process In Alpha")
        end
      end

      it "preserves selected items when filters change" do
        # Select a process first
        open_tom_select
        find(".ts-dropdown .option", text: "Process In Alpha").click

        # Change filter to a different group — selected item should stay
        select "Any group", from: "content_block_settings_process_group_id"

        within "[data-awesome-processes-manual] .ts-control" do
          expect(page).to have_content("Process In Alpha")
        end
      end

      it "reorders items with arrow buttons and persists order after save" do
        open_tom_select
        find(".ts-dropdown .option", text: "Process In Alpha").click
        open_tom_select
        find(".ts-dropdown .option", text: "Process Outside").click

        # Move second item up
        items = all("[data-awesome-processes-manual] .ts-control [data-value]")
        expect(items[0]).to have_content("Process In Alpha")
        expect(items[1]).to have_content("Process Outside")

        items[1].find(".reorder-up").click

        items = all("[data-awesome-processes-manual] .ts-control [data-value]")
        expect(items[0]).to have_content("Process Outside")
        expect(items[1]).to have_content("Process In Alpha")

        # Save and reload
        click_link_or_button "Update"
        visit decidim_admin.edit_organization_homepage_content_block_path(content_block)
        select "Manual", from: "content_block_settings_selection_criteria"

        items = all("[data-awesome-processes-manual] .ts-control [data-value]")
        expect(items[0]).to have_content("Process Outside")
        expect(items[1]).to have_content("Process In Alpha")
      end
    end

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

    context "when no published processes exist" do
      before do
        Decidim::ParticipatoryProcess.where(organization:).destroy_all
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
