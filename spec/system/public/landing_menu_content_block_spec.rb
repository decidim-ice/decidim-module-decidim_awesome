# frozen_string_literal: true

require "spec_helper"

describe "Public homepage shows Landing Menu block" do
  let(:organization) { create(:organization) }
  let!(:content_block) { create(:content_block, organization:, manifest_name: :awesome_landing_menu, scope_name: :homepage, settings:) }
  let(:settings) { { "menu_items" => menu_items_json, "sticky" => sticky, "alignment" => alignment } }
  let(:menu_items_json) { [{ "name" => { "en" => "Contact" }, "url" => "https://example.com", "visible" => true }].to_json }
  let(:sticky) { false }
  let(:alignment) { "center" }

  before do
    switch_to_host(organization.host)
  end

  context "with multiple menu items" do
    let(:menu_items_json) do
      [
        { "name" => { "en" => "About" }, "url" => "/about", "visible" => true },
        { "name" => { "en" => "Contact" }, "url" => "/contact", "visible" => true },
        { "name" => { "en" => "FAQ" }, "url" => "/faq", "visible" => true }
      ].to_json
    end

    it "displays all items in order" do
      visit decidim.root_path
      within(".awesome-landing-menu") do
        expect(page).to have_content("About")
        expect(page).to have_content("Contact")
        expect(page).to have_content("FAQ")
      end
    end

    it "displays items in the stored order" do
      visit decidim.root_path
      within(".awesome-landing-menu") do
        items = all("a").map(&:text)
        expect(items).to eq(["About", "Contact", "FAQ"])
      end
    end

    context "when items are stored in a different order" do
      let(:menu_items_json) do
        [
          { "name" => { "en" => "FAQ" }, "url" => "/faq", "visible" => true },
          { "name" => { "en" => "About" }, "url" => "/about", "visible" => true },
          { "name" => { "en" => "Contact" }, "url" => "/contact", "visible" => true }
        ].to_json
      end

      it "renders items in the reordered sequence" do
        visit decidim.root_path
        within(".awesome-landing-menu") do
          items = all("a").map(&:text)
          expect(items).to eq(["FAQ", "About", "Contact"])
        end
      end
    end
  end

  context "with external link" do
    it "displays the link text" do
      visit decidim.root_path
      within(".awesome-landing-menu") do
        expect(page).to have_content("Contact")
      end
    end

    it "opens external link in new tab" do
      visit decidim.root_path
      within(".awesome-landing-menu") do
        expect(page).to have_css("a[target='_blank'][rel='noopener noreferrer']", text: "Contact")
      end
    end
  end

  context "with relative path link" do
    let(:menu_items_json) { [{ "name" => { "en" => "About" }, "url" => "/about-us", "visible" => true }].to_json }

    it "displays the internal link" do
      visit decidim.root_path
      within(".awesome-landing-menu") do
        expect(page).to have_link("About", href: "/about-us")
      end
    end
  end

  context "with anchor to an existing content block" do
    let!(:sibling_block) { create(:content_block, organization:, manifest_name: :awesome_landing_menu, scope_name: :homepage, settings: sibling_settings) }
    let(:sibling_settings) { { "menu_items" => [{ "name" => { "en" => "Home" }, "url" => "#hero", "visible" => true }].to_json } }
    let(:menu_items_json) { [{ "name" => { "en" => "Go to sibling" }, "url" => "#awesome-landing-menu-#{sibling_block.id}", "visible" => true }].to_json }

    it "displays the anchor link" do
      visit decidim.root_path
      within("#awesome-landing-menu-#{content_block.id}") do
        expect(page).to have_content("Go to sibling")
      end
    end
  end

  context "when URL is unsafe" do
    let(:menu_items_json) do
      [
        { "name" => { "en" => "XSS" }, "url" => "javascript:alert(1)", "visible" => true },
        { "name" => { "en" => "Safe" }, "url" => "/about", "visible" => true }
      ].to_json
    end

    it "does not render the unsafe link" do
      visit decidim.root_path
      within(".awesome-landing-menu") do
        expect(page).to have_no_content("XSS")
        expect(page).to have_content("Safe")
      end
    end
  end

  context "when menu_items is empty" do
    let(:menu_items_json) { "[]" }

    it "does not render the menu" do
      visit decidim.root_path
      expect(page).to have_no_css(".awesome-landing-menu")
    end
  end

  context "when sticky is true" do
    let(:sticky) { true }

    it "renders nav with sticky class" do
      visit decidim.root_path
      expect(page).to have_css("section.awesome-landing-menu--sticky")
    end
  end

  context "when sticky is false" do
    let(:sticky) { false }

    it "renders nav without sticky class" do
      visit decidim.root_path
      within(".awesome-landing-menu") do
        expect(page).to have_no_css("section.awesome-landing-menu--sticky")
      end
    end
  end

  context "when alignment is left" do
    let(:alignment) { "left" }

    it "renders with justify-start class" do
      visit decidim.root_path
      expect(page).to have_css(".awesome-landing-menu .awesome-landing-menu__container--left")
    end
  end

  context "when alignment is right" do
    let(:alignment) { "right" }

    it "renders with justify-end class" do
      visit decidim.root_path
      expect(page).to have_css(".awesome-landing-menu .awesome-landing-menu__container--right")
    end
  end

  context "when alignment is center" do
    let(:alignment) { "center" }

    it "renders with justify-center class" do
      visit decidim.root_path
      expect(page).to have_css(".awesome-landing-menu .awesome-landing-menu__container--center")
    end
  end
end
