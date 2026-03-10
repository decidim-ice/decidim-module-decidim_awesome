# frozen_string_literal: true

require "spec_helper"

describe "Public homepage shows Landing Menu block" do
  let(:organization) { create(:organization) }
  let!(:content_block) { create(:content_block, organization:, manifest_name: :awesome_landing_menu, scope_name: :homepage, settings:) }
  let(:settings) { { "menu_items" => { "en" => menu_items_text }, "sticky" => sticky, "alignment" => alignment } }
  let(:menu_items_text) { "Contact | https://example.com | _blank" }
  let(:sticky) { false }
  let(:alignment) { "center" }

  before do
    switch_to_host(organization.host)
  end

  context "with external link" do
    it "displays the link text" do
      visit decidim.root_path
      within(".landing-menu") do
        expect(page).to have_content("Contact")
      end
    end

    it "opens external link in new tab" do
      visit decidim.root_path
      within(".landing-menu") do
        expect(page).to have_css("a[target='_blank'][rel='noopener noreferrer']", text: "Contact")
      end
    end
  end

  context "with anchor to an existing content block" do
    let!(:sibling_block) { create(:content_block, organization:, manifest_name: :awesome_landing_menu, scope_name: :homepage, settings: sibling_settings) }
    let(:sibling_settings) { { "menu_items" => { "en" => "Home | #hero" } } }
    let(:menu_items_text) { "Go to sibling | #awesome-landing-menu-#{sibling_block.id}" }

    it "displays the anchor link" do
      visit decidim.root_path
      within("#awesome-landing-menu-#{content_block.id}") do
        expect(page).to have_content("Go to sibling")
      end
    end
  end

  context "when anchor points to a non-existent element" do
    let(:menu_items_text) { "Missing | #nonexistent-block" }

    it "hides the link via JavaScript" do
      visit decidim.root_path
      expect(page).to have_no_content("Missing")
    end
  end

  context "when menu_items is empty" do
    let(:menu_items_text) { "" }

    it "does not render the menu" do
      visit decidim.root_path
      expect(page).to have_no_css(".landing-menu")
    end
  end

  context "when sticky is true" do
    let(:sticky) { true }

    it "renders nav with sticky class" do
      visit decidim.root_path
      expect(page).to have_css("nav.sticky")
    end
  end

  context "when sticky is false" do
    let(:sticky) { false }

    it "renders nav without sticky class" do
      visit decidim.root_path
      within(".landing-menu") do
        expect(page).to have_no_css("nav.sticky")
      end
    end
  end

  context "when alignment is left" do
    let(:alignment) { "left" }

    it "renders with justify-start class" do
      visit decidim.root_path
      expect(page).to have_css(".landing-menu .justify-start")
    end
  end

  context "when alignment is right" do
    let(:alignment) { "right" }

    it "renders with justify-end class" do
      visit decidim.root_path
      expect(page).to have_css(".landing-menu .justify-end")
    end
  end

  context "when alignment is center" do
    let(:alignment) { "center" }

    it "renders with justify-center class" do
      visit decidim.root_path
      expect(page).to have_css(".landing-menu .justify-center")
    end
  end
end
