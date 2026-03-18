# frozen_string_literal: true

require "spec_helper"

describe "Admin manages Awesome Rich Text content block" do
  let(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  describe "adding the block" do
    before do
      visit decidim_admin.edit_organization_homepage_path
    end

    it "lists 'Awesome Rich Text block' in the add content block dropdown" do
      click_link_or_button "Add content block"
      expect(page).to have_content("Awesome Rich Text block")
    end

    it "can add the block" do
      click_link_or_button "Add content block"
      click_link_or_button "Awesome Rich Text block"

      expect(page).to have_content("Content block successfully created")
    end
  end

  describe "editing block settings" do
    let!(:content_block) { create(:content_block, organization:, manifest_name: :awesome_rich_text, scope_name: :homepage) }

    before do
      visit decidim_admin.edit_organization_homepage_content_block_path(content_block)
    end

    it "displays the settings form with all fields" do
      expect(page).to have_content("Awesome Rich Text block")
      expect(page).to have_field("content_block_settings_block_id")
      expect(page).to have_field("content_block_settings_title_en")
    end

    it "saves and persists block_id and title" do
      fill_in "content_block_settings_block_id", with: "our-team"
      fill_in "content_block_settings_title_en", with: "Our Team"
      click_link_or_button "Update"
      expect(page).to have_content("Homepage layout")

      visit decidim_admin.edit_organization_homepage_content_block_path(content_block)
      expect(page).to have_field("content_block_settings_block_id", with: "our-team")
      expect(page).to have_field("content_block_settings_title_en", with: "Our Team")
    end

    it "shows the transparent background checkbox" do
      expect(page).to have_content("Transparent background")
    end
  end
end
