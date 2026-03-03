# frozen_string_literal: true

require "spec_helper"

describe "Admin manages Awesome Process Groups content block" do
  let(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let!(:process_group) { create(:participatory_process_group, organization:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  describe "adding the block" do
    before do
      visit decidim_admin_participatory_processes.edit_participatory_process_group_landing_page_path(process_group)
    end

    it "lists 'Awesome group processes' in the add content block dropdown" do
      click_link_or_button "Add content block"
      expect(page).to have_content("Awesome group processes")
    end

    it "can add the block" do
      click_link_or_button "Add content block"
      click_link_or_button "Awesome group processes"

      expect(page).to have_content("Content block successfully created")
    end
  end

  describe "editing block settings" do
    let!(:content_block) do
      create(:content_block, organization:, manifest_name: :awesome_process_groups,
                             scope_name: :participatory_process_group_homepage,
                             scoped_resource_id: process_group.id)
    end

    before do
      visit decidim_admin_participatory_processes.edit_participatory_process_group_landing_page_content_block_path(process_group, content_block)
    end

    it "displays the settings form with all fields" do
      expect(page).to have_content("Awesome group processes")
      expect(page).to have_field("content_block_settings_title_en")
      expect(page).to have_field("content_block_settings_max_count")
    end

    it "saves and persists the title" do
      fill_in "content_block_settings_title_en", with: "Our Group Processes"
      click_link_or_button "Update"

      visit decidim_admin_participatory_processes.edit_participatory_process_group_landing_page_content_block_path(process_group, content_block)
      expect(page).to have_field("content_block_settings_title_en", with: "Our Group Processes")
    end

    it "saves and persists max_count" do
      fill_in "content_block_settings_max_count", with: 3
      click_link_or_button "Update"

      visit decidim_admin_participatory_processes.edit_participatory_process_group_landing_page_content_block_path(process_group, content_block)
      expect(page).to have_field("content_block_settings_max_count", with: "3")
    end
  end
end
