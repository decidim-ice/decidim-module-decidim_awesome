# frozen_string_literal: true

require "spec_helper"

describe "Show awesome iframe", type: :system do
  include_context "with a component"
  let(:manifest_name) { "awesome_iframe" }

  let!(:user) { create :user, :confirmed, organization: organization }
  let(:settings) do
    {
      announcement: announcement,
      iframe: iframe,
      no_margins: no_margins,
      viewport_width: viewport_width
    }
  end

  let(:iframe) { '<iframe src="https://test.test"></iframe>' }
  let(:no_margins) { false }
  let(:viewport_width) { false }
  let(:announcement) { {} }

  before do
    component.update!(settings: settings)
    visit_component
    unless legacy_version?
      click_link "Change cookie settings"
      click_button "Accept all"
    end
  end

  it "shows the iframe wrapper" do
    within ".wrapper" do
      expect(page).to have_selector(".awesome-iframe")
    end
  end

  it "shows the iframe" do
    within ".awesome-iframe" do
      expect(page).to have_selector("iframe")
    end
  end

  context "when announcement is present" do
    let(:announcement) do
      {
        en: "I'm awesome!"
      }
    end

    it "shows the announcement" do
      within ".wrapper" do
        expect(page).to have_content("I'm awesome!")
      end
    end
  end

  context "when no_margins is enabled" do
    let(:no_margins) { true }

    it "removes the css margin" do
      expect(page).to have_selector(".wrapper")
      expect(page.execute_script("return $('.wrapper').css('padding-left')")).to eq("0px")
      expect(page.execute_script("return $('.wrapper').css('padding-right')")).to eq("0px")
      expect(page.execute_script("return $('.wrapper').css('padding-bottom')")).to eq("0px")
      expect(page.execute_script("return $('.wrapper').css('padding-top')")).to eq("0px")
    end

    context "and announcement is present" do
      let(:announcement) do
        {
          en: "I'm awesome!"
        }
      end

      it "has margin on top" do
        expect(page.execute_script("return $('.wrapper').css('padding-left')")).to eq("0px")
        expect(page.execute_script("return $('.wrapper').css('padding-right')")).to eq("0px")
        expect(page.execute_script("return $('.wrapper').css('padding-bottom')")).to eq("0px")
        expect(page.execute_script("return $('.wrapper').css('padding-top')")).not_to eq("0px")
      end
    end
  end

  context "when viewport_width is enabled" do
    let(:viewport_width) { true }

    it "adds the .row class" do
      within ".wrapper" do
        expect(page).to have_selector(".awesome-iframe.row")
      end
    end
  end

  context "when iframe code contains a script in srcdoc" do
    let(:iframe) { '<iframe srcdoc="<script>alert(\'XSS\');</script>"></iframe>' }

    it "removes the script" do
      within ".awesome-iframe" do
        expect(page).not_to have_selector("script")
        expect(page).to have_selector("iframe")
        expect(page).not_to have_text("XSS")
        expect { page.driver.browser.switch_to.alert }.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
      end
    end
  end
end
