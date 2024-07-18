# frozen_string_literal: true

require "spec_helper"

describe "Show awesome iframe" do
  include_context "with a component"
  let(:manifest_name) { "awesome_iframe" }

  let!(:user) { create(:user, :confirmed, organization:) }
  let(:settings) do
    {
      announcement:,
      iframe:,
      viewport_width:
    }
  end

  let(:iframe) { '<iframe src="https://test.test"></iframe>' }
  let(:viewport_width) { false }
  let(:announcement) { {} }

  before do
    component.update!(settings:)
    visit_component
    click_link_or_button "Change cookie settings"
    click_link_or_button "Accept all"
  end

  it "shows the iframe wrapper" do
    within "[data-content]" do
      expect(page).to have_css(".awesome-iframe")
    end
  end

  it "shows the iframe" do
    within ".awesome-iframe" do
      expect(page).to have_css("iframe")
    end
  end

  it "adds the #html-block-html id" do
    within "[data-content]" do
      expect(page).to have_css("#html-block-html.awesome-iframe")
    end
  end

  context "when announcement is present" do
    let(:announcement) do
      {
        en: "I'm awesome!"
      }
    end

    it "shows the announcement" do
      within "[data-content]" do
        expect(page).to have_content("I'm awesome!")
      end
    end
  end

  context "when viewport_width is enabled" do
    let(:viewport_width) { true }

    it "adds the #iframe-block id" do
      within "[data-content]" do
        expect(page).to have_css("#iframe-block.awesome-iframe")
      end
    end
  end

  context "when iframe code contains a script in srcdoc" do
    let(:iframe) { '<iframe srcdoc="<script>alert(\'XSS\');</script>"></iframe>' }

    it "removes the script" do
      within ".awesome-iframe" do
        expect(page).not_to have_css("script")
        expect(page).to have_css("iframe")
        expect(page).not_to have_text("XSS")
        expect { page.driver.browser.switch_to.alert }.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
      end
    end
  end
end
