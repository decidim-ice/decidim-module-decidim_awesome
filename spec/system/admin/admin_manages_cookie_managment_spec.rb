# frozen_string_literal: true

require "spec_helper"

describe "Admin manages cookie managment" do
  let(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:var_name) { :cookie_management }
  let!(:config) { create(:awesome_config, organization:, var: var_name, value: {}) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  describe "cookie categories" do
    before do
      visit decidim_admin_decidim_awesome.config_path(:cookie_management)
    end

    it "creates a new category" do
      click_on "New category"
      fill_in :cookie_category_slug, with: "galleta"
      fill_in :cookie_category_title_en, with: "Galleta"
      fill_in :cookie_category_description_en, with: "We use galletas to improve your experience on our site."
      click_button "Save"

      expect(page).to have_content("Cookie Management")
      expect(page).to have_content("Cookie category created successfully")
      within ".decidim_awesome-form" do
        expect(page).to have_content("galleta")
        expect(page).to have_content("Galleta")
      end
    end

    context "when updating/deleting a category" do
      let(:category_slug) { "galleta" }
      let(:existing_categories) do
        {
          category_slug => {
            "slug" => category_slug,
            "title" => { "en" => "Galleta" },
            "description" => { "en" => "We use galletas to improve your experience on our site." },
            "mandatory" => false,
            "visibility" => "visible",
            "edited" => true,
            "items" => {}
          }
        }
      end

      before do
        config.update!(value: existing_categories)
        visit decidim_admin_decidim_awesome.config_path(:cookie_management)
      end

      it "edits the category" do
        within all(".decidim_awesome-form tr")[5] do
          click_on "Edit category"
        end

        fill_in :cookie_category_slug, with: "galleta-updated"
        fill_in :cookie_category_title_en, with: "Galleta Updated"
        click_button "Save"

        expect(page).to have_content("Cookie Management")
        within ".decidim_awesome-form" do
          expect(page).to have_content("galleta-updated")
          expect(page).to have_content("Galleta Updated")
        end
      end

      it "deletes the category" do
        within all(".decidim_awesome-form tr")[5] do
          accept_confirm { click_on "Remove customization" }
        end

        expect(page).to have_content("Cookie Management")
        expect(page).to have_no_content("galleta")
        expect(page).to have_no_content("Galleta")
      end
    end
  end

  describe "cookie items" do
    let(:category_slug) { "galleta" }
    let(:existing_categories) do
      {
        category_slug => {
          "slug" => category_slug,
          "title" => { "en" => "Galleta" },
          "description" => { "en" => "We use galletas to improve your experience on our site." },
          "mandatory" => false,
          "visibility" => "visible",
          "edited" => true,
          "items" => {}
        }
      }
    end

    before do
      config.update!(value: existing_categories)
      visit decidim_admin_decidim_awesome.config_path(:cookie_management)
      within all(".decidim_awesome-form tr")[5] do
        click_on "Category items"
      end
    end

    it "creates a new item in a category" do
      click_on "New item"
      fill_in :cookie_item_name, with: "youtube-analytics"
      fill_in :cookie_item_service_en, with: "This website"
      fill_in :cookie_item_expiration_en, with: "session"
      fill_in :cookie_item_description_en, with: "Our youtube analytics cookies are the best!"
      click_button "Save"

      expect(page).to have_content("Cookie items")
      expect(page).to have_content("Cookie item created successfully")
      within all(".decidim_awesome-form tr")[1] do
        expect(page).to have_content("youtube-analytics")
        expect(page).to have_content("This website")
        expect(page).to have_content("session")
      end
    end

    it "adds presets items to a category" do
      click_on "Common cookie services"

      accept_confirm { click_on "Facebook Pixel" }
      within all(".decidim_awesome-form tr")[1] do
        expect(page).to have_content("Meta")
        expect(page).to have_content("3 months")
      end
    end

    context "when updating/deleting an item" do
      let(:item_name) { "youtube-analytics" }
      let(:existing_categories_with_items) do
        {
          category_slug => {
            "slug" => category_slug,
            "title" => { "en" => "Galleta" },
            "description" => { "en" => "We use galletas to improve your experience on our site." },
            "mandatory" => false,
            "visibility" => "visible",
            "edited" => true,
            "items" => {
              item_name => {
                "name" => item_name,
                "service" => { "en" => "This website" },
                "expiration" => { "en" => "session" },
                "description" => { "en" => "Our youtube analytics cookies are the best!" },
                "edited" => true
              }
            }
          }
        }
      end

      before do
        config.update!(value: existing_categories_with_items)
        visit decidim_admin_decidim_awesome.config_path(:cookie_management)
        within all(".decidim_awesome-form tr")[5] do
          click_on "Category items"
        end
      end

      it "edits the item" do
        within all(".decidim_awesome-form tr")[1] do
          click_on "Edit item"
        end

        fill_in :cookie_item_service_en, with: "This awesome website"
        click_button "Save"

        expect(page).to have_content("Cookie item updated successfully")
        expect(page).to have_content("Cookie items")
        within all(".decidim_awesome-form tr")[1] do
          expect(page).to have_content("This awesome website")
        end
      end

      it "deletes the item" do
        within all(".decidim_awesome-form tr")[1] do
          accept_confirm { click_on "Remove customization" }
        end

        expect(page).to have_content("Cookie items")
        expect(page).to have_no_content("youtube-analytics")
      end
    end
  end
end
