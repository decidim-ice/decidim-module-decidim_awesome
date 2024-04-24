# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/menu_hack_contexts"

describe "Admin manages hacked menus" do
  let(:organization) { create(:organization) }
  let!(:config) { create(:awesome_config, organization:, var: menu_name, value: previous_menu) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:participatory_process) { create(:participatory_process, organization:) }
  let(:previous_menu) do
    []
  end

  include_context "with menu hacks params"

  shared_examples "admin manages menu overrides" do
    before do
      Decidim::MenuRegistry.register menu_id do |menu|
        menu.add_item :native_menu,
                      "Native",
                      "/some-path?locale=ca",
                      position: 5
      end
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_decidim_awesome.menu_hacks_path(menu_id:)
    end

    after do
      Decidim::MenuRegistry.find(menu_id).configurations.pop
    end

    context "when visiting the index" do
      it "shows default menu items" do
        within "table tbody" do
          default_menu_labels.each do |label|
            expect(page).to have_content(label)
          end
        end
      end

      it "allows to edit a default item" do
        within "tr", text: default_menu_item[:label] do
          click_link_or_button "Edit"
        end

        fill_in "menu_raw_label_en", with: "A new beggining"
        click_link_or_button "Save"

        within "table tbody" do
          expect(page).to have_content("A new beggining")
          expect(page).to have_no_content("Home")
        end
      end

      it "allows to create a new item" do
        click_link_or_button "New item"

        fill_in "menu_raw_label_en", with: "Blog"
        fill_in "menu_url", with: "http://external.blog"
        fill_in "menu_position", with: "1.5"

        click_link_or_button "Save"

        within "table tbody" do
          default_menu_labels.each do |label|
            expect(page).to have_content(label)
          end
          expect(page).to have_content("Blog")
          expect(page).to have_content("http://external.blog")
        end
      end

      context "when native menu has query strings" do
        it "allows to edit it" do
          within "tr", text: "Native" do
            click_link_or_button "Edit"
          end

          fill_in "menu_raw_label_en", with: "Native edited"
          click_link_or_button "Save"

          within "table tbody" do
            expect(page).to have_content("Native edited")
            expect(page).to have_content("/some-path")
            expect(page).to have_no_content("/some-path?locale=ca")
          end
        end
      end

      context "when menu has overrides" do
        include_context "with menu hacks params"

        let(:url) { default_menu_item[:path] }
        let(:previous_menu) do
          [{ "url" => url, "label" => { "en" => "A new beggining" }, "position" => 10 }]
        end

        it "shows default and overrides menu items" do
          within "table tbody" do
            expect(page).to have_content("A new beggining")
            expect(page).to have_no_content(default_menu_item[:label])
            (default_menu_labels - [default_menu_item[:label]]).each do |label|
              expect(page).to have_content(label)
            end
          end
        end

        it "can be edited" do
          within "tr", text: "A new beggining" do
            click_link_or_button "Edit"
          end

          fill_in "menu_raw_label_en", with: "Another thing"
          click_link_or_button "Save"

          within "table tbody" do
            expect(page).to have_content("Another thing")
            expect(page).to have_no_content("A new beggining")
            expect(page).to have_no_content("Home")
          end
        end

        it "can be deleted" do
          within "tr", text: "A new beggining" do
            accept_confirm { click_link_or_button "Remove customization" }
          end

          within "table tbody" do
            expect(page).to have_content(default_menu_item[:label])
            expect(page).to have_no_content("A new beggining")
          end
        end
      end

      context "when menu has new items" do
        include_context "with menu hacks params"

        let(:url) { "/a-new-link" }
        let(:previous_menu) do
          [{ "url" => url, "label" => { "en" => "A new link" }, "position" => 10 }]
        end

        it "shows default and overrides menu items" do
          within "table tbody" do
            default_menu_labels.each do |label|
              expect(page).to have_content(label)
            end
            expect(page).to have_content("A new link")
          end
        end

        it "can be edited" do
          within "tr", text: "A new link" do
            click_link_or_button "Edit"
          end

          fill_in "menu_raw_label_en", with: "Another thing"
          click_link_or_button "Save"

          within "table tbody" do
            expect(page).to have_content("Another thing")
            expect(page).to have_no_content("A new link")
          end
        end

        it "can be deleted" do
          within "tr", text: "A new link" do
            accept_confirm { click_link_or_button "Remove addition" }
          end

          within "table tbody" do
            expect(page).to have_no_content("A new link")
          end
        end
      end
    end
  end

  context "with main menu" do
    let!(:menu_name) { "menu" }
    let(:default_menu_labels) { %w(Home Processes Help) }
    let(:default_menu_item) { { label: "Home", path: "/" } }

    it_behaves_like "admin manages menu overrides"
  end

  context "with home content block menu" do
    let!(:menu_name) { "home_content_block_menu" }
    let(:default_menu_labels) { %w(Processes) }
    let(:default_menu_item) { { label: "Processes", path: "/processes" } }

    it_behaves_like "admin manages menu overrides"
  end
end
