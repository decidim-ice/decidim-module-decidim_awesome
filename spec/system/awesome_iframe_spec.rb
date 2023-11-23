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
      viewport_width: viewport_width
    }
  end

  let(:iframe) { '<iframe src="https://test.test"></iframe>' }
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

  context "when viewport_width is enabled" do
    let(:viewport_width) { true }

    it "adds the .row class" do
      within ".wrapper" do
        expect(page).to have_selector(".awesome-iframe.row")
      end
    end
  end
end
