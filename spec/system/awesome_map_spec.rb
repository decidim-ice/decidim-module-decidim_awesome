# frozen_string_literal: true

require "spec_helper"

describe "Show awesome map", type: :system do
  include_context "with a component"
  let(:manifest_name) { "awesome_map" }

  let!(:proposal_component) { create(:proposal_component, :with_amendments_enabled, :with_geocoding_enabled, participatory_space: participatory_process) }
  let!(:proposal) { create(:proposal, component: proposal_component, latitude: 40, longitude: 2) }
  let(:emendation) { build(:proposal, component: proposal_component, latitude: 42, longitude: 4) }
  let!(:proposal_amendment) { create(:proposal_amendment, amendable: proposal, emendation: emendation) }

  let!(:category) { create(:category, participatory_space: participatory_process) }
  let!(:subcategory) { create(:subcategory, parent: category, participatory_space: participatory_process) }
  let!(:user) { create :user, :confirmed, organization: organization }
  let(:settings) do
    {
      menu_amendments: show_amendments,
      menu_meetings: show_meetings
    }
  end
  let(:show_amendments) { true }
  let(:show_meetings) { true }

  before do
    visit_component
  end

  it "shows the map" do
    within ".wrapper" do
      expect(page).to have_selector(".awesome-map")
      expect(page).to have_selector("#awesome-map")
      errors = if legacy_version?
                 page.driver.browser.manage.logs.get(:browser)
               else
                 page.driver.browser.logs.get(:browser)
               end

      errors.each do |error|
        expect(error.message).not_to include("map.js"), error.message if error.level == "SEVERE"
      end
    end
  end

  it "has AwesomeMap javascript and CSS" do
    within "head", visible: :all do
      expect(page).to have_xpath("//link[@rel='stylesheet'][contains(@href,'decidim_decidim_awesome_map')]", visible: :all)
      expect(page).to have_xpath("//link[@rel='stylesheet'][contains(@href,'decidim_map')]", visible: :all)
    end
    within(legacy_version? ? "head" : ".wrapper", visible: :all) do
      expect(page).to have_xpath("//script[contains(@src,'decidim_decidim_awesome_map')]", visible: :all)
      expect(page).to have_xpath("//script[contains(@src,'decidim_map')]", visible: :all)
    end
  end

  it "shows categories and colors" do
    within ".awesome-map" do
      expect(page.body).to have_content(".awesome_map-category_#{category.id}")
      expect(page.body).to have_content(".awesome_map-category_#{subcategory.id}")
    end
  end

  # TODO: figure out a way to test leaflet without any map provider
  # it "shows the proposal component as a menu" do
  #   expect(page.body).to have_content(".awesome_map-component_#{component.id}")
  # end

  # it "shows amendments as a menu" do
  #   expect(page.body).to have_content(".awesome_map-amendments_#{component.id}")
  # end

  # context "when hiding admendments" do
  #   let(:show_amendments) { false }

  #   it "do not show the admendments menu item" do
  #   end
  # end

  # context "when hiding meetings" do
  #   let(:show_meetings) { true }

  #   it "do not show the meetings menu item" do
  #   end
  # end
end
