# frozen_string_literal: true

require "spec_helper"

describe "Admin manages Landing Menu content block" do
  let(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  describe "editing block settings" do
    let!(:content_block) { create(:content_block, organization:, manifest_name: :awesome_landing_menu, scope_name: :homepage, settings:) }
    let(:settings) { {} }

    before do
      visit decidim_admin.edit_organization_homepage_content_block_path(content_block)
    end

    it "displays the settings form with all fields" do
      expect(page).to have_content("Landing menu")
      expect(page).to have_content("Sticky")
      expect(page).to have_content("Menu position")
      expect(page).to have_content("Menu items")
    end

    it "displays help text for alignment" do
      expect(page).to have_content("Align menu items to the left, center, or right of the page")
    end

    it "displays help text for menu items" do
      expect(page).to have_content("One item per line.")
    end

    it "saves sticky setting" do
      check "content_block_settings_sticky"
      click_link_or_button "Update"

      visit decidim_admin.edit_organization_homepage_content_block_path(content_block)
      expect(page).to have_checked_field("content_block_settings_sticky")
    end

    it "saves alignment setting" do
      select "Left", from: "content_block_settings_alignment"
      click_link_or_button "Update"

      visit decidim_admin.edit_organization_homepage_content_block_path(content_block)
      expect(page).to have_select("content_block_settings_alignment", selected: "Left")
    end

    it "saves menu items" do
      fill_in "content_block_settings_menu_items_en", with: "About | #hero\nContact | https://example.com | _blank"
      click_link_or_button "Update"

      visit decidim_admin.edit_organization_homepage_content_block_path(content_block)
      expect(page).to have_field("content_block_settings_menu_items_en", with: "About | #hero\nContact | https://example.com | _blank")
    end

    it "saves all settings together" do
      check "content_block_settings_sticky"
      select "Right", from: "content_block_settings_alignment"
      fill_in "content_block_settings_menu_items_en", with: "Home | #hero\nAbout | /about | _blank"
      click_link_or_button "Update"

      visit decidim_admin.edit_organization_homepage_content_block_path(content_block)
      expect(page).to have_checked_field("content_block_settings_sticky")
      expect(page).to have_select("content_block_settings_alignment", selected: "Right")
      expect(page).to have_field("content_block_settings_menu_items_en", with: "Home | #hero\nAbout | /about | _blank")
    end

    describe "anchor chips" do
      let!(:html_block) { create(:content_block, organization:, manifest_name: :html, scope_name: :homepage) }

      before do
        visit decidim_admin.edit_organization_homepage_content_block_path(content_block)
      end

      it "displays chips for existing published content blocks" do
        expect(page).to have_content("Click to add or remove:")
        expect(page).to have_css("[data-landing-menu-anchors]")
        expect(page).to have_css("[data-anchor-label]")
      end

      it "adds anchor line to textarea when chip is clicked" do
        chip = first("[data-anchor-label]")
        label = chip["data-anchor-label"]
        url = chip["data-anchor-url"]
        chip.click
        textarea = find_by_id("content_block_settings_menu_items_en", visible: :all)
        expect(textarea.value).to include("#{label} | #{url}")
      end

      it "removes anchor line when active chip is clicked again" do
        chip = first("[data-anchor-label]")
        chip.click
        chip.click
        textarea = find_by_id("content_block_settings_menu_items_en", visible: :all)
        expect(textarea.value.strip).to eq("")
      end
    end
  end
end
