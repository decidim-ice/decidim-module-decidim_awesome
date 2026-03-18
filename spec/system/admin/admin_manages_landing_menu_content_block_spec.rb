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

    it "displays the settings form" do
      expect(page).to have_content("Awesome global menu")
      expect(page).to have_content("Sticky")
      expect(page).to have_content("Show on mobile screens")
      expect(page).to have_content("Menu position")
      expect(page).to have_content("Add new item")
    end

    it "displays CSS help text with link" do
      expect(page).to have_content("custom style")
      expect(page).to have_content(".awesome-landing-menu")
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

    describe "adding a new menu item" do
      it "shows global menu links in presets" do
        click_link_or_button "Add new item"

        within "#item-form" do
          expect(page).to have_content("Autofill presets")
          expect(page).to have_css("optgroup[label='Decidim usual suspects']")
          expect(page).to have_css("option", text: "Home")
        end
      end

      context "with participatory processes" do
        let!(:participatory_process) { create(:participatory_process, organization:) }

        it "shows processes in global menu presets" do
          click_link_or_button "Add new item"

          within "#item-form" do
            within "optgroup[label='Decidim usual suspects']" do
              expect(page).to have_css("option", text: "Processes")
            end
          end
        end
      end

      context "with sibling content blocks" do
        let!(:sibling_block) { create(:content_block, organization:, manifest_name: :html, scope_name: :homepage) }

        it "shows content block anchors in presets" do
          click_link_or_button "Add new item"

          within "#item-form" do
            expect(page).to have_css("optgroup[label='Existing content blocks']")
          end
        end
      end
    end

    context "with existing menu items" do
      let(:menu_items) do
        [{ "name" => { "en" => "About" }, "url" => "#about", "visible" => true },
         { "name" => { "en" => "Contact" }, "url" => "https://example.com", "visible" => false }].to_json
      end
      let(:settings) { { "menu_items" => menu_items } }

      it "displays items in the table" do
        expect(page).to have_content("About")
        expect(page).to have_content("#about")
        expect(page).to have_content("Contact")
        expect(page).to have_content("https://example.com")
      end

      it "toggles item visibility" do
        within "tr[data-record-id='0']" do
          find("a[href*='toggle_visible']").click
        end

        content_block.reload
        items = Decidim::DecidimAwesome::MenuItemsParser.parse_json(content_block.settings.menu_items)
        expect(items.first["visible"]).to be(false)
      end

      it "deletes an item" do
        accept_confirm do
          within "tr[data-record-id='1']" do
            find("a[data-method='delete']").click
          end
        end

        expect(page).to have_no_content("Contact")
        content_block.reload
        items = Decidim::DecidimAwesome::MenuItemsParser.parse_json(content_block.settings.menu_items)
        expect(items.length).to eq(1)
      end
    end
  end
end
