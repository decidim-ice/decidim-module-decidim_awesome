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

    it "shows restrict checkboxes" do
      expect(page).to have_content("Prevent embed videos")
      expect(page).to have_content("Prevent links")
    end

    it "shows background image placement select" do
      expect(page).to have_content("Image placement")
    end

    it "shows the add column button" do
      expect(page).to have_content("Add a new column")
    end

    it "does not show remove button for the first column" do
      expect(page).to have_no_button("Remove")
    end

    context "with multiple columns" do
      let!(:content_block) do
        create(:content_block, organization:, manifest_name: :awesome_rich_text, scope_name: :homepage,
                               settings: { "columns" => [{ "body" => { "en" => "Col 1" } }, { "body" => { "en" => "Col 2" } }] })
      end

      it "displays all columns on the edit page" do
        expect(page).to have_content("Column")
        expect(all(".awesome-rich-text-column").count).to eq(2)
      end

      it "shows remove button for columns after the first" do
        within all(".awesome-rich-text-column").last do
          expect(page).to have_button("Remove")
        end
      end
    end
  end
end
