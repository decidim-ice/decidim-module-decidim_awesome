# frozen_string_literal: true

require "spec_helper"

describe "Show awesome map", type: :system do
  include_context "with a component"
  let(:manifest_name) { "awesome_map" }

  let!(:proposal_component) { create(:proposal_component, :with_amendments_enabled, :with_geocoding_enabled, participatory_space: participatory_process) }
  let!(:proposal) { create(:proposal, component: proposal_component, latitude: 40, longitude: 2) }
  let(:emendation) { build(:proposal, component: proposal_component, latitude: 42, longitude: 4) }
  let!(:proposal_amendment) { create(:proposal_amendment, amendable: proposal, emendation: emendation) }
  let!(:accepted_proposal) { create(:proposal, :accepted, component: proposal_component, latitude: 50, longitude: 2) }
  let!(:evaluating_proposal) { create(:proposal, :evaluating, component: proposal_component, latitude: 48, longitude: 4) }
  let!(:not_answered_proposal) { create(:proposal, :not_answered, component: proposal_component, latitude: 60, longitude: 6) }
  let!(:withdrawn_proposal) { create(:proposal, :withdrawn, component: proposal_component, latitude: 60, longitude: 2) }
  let!(:rejected_proposal) { create(:proposal, :rejected, component: proposal_component, latitude: 10, longitude: 2) }
  let!(:category) { create(:category, participatory_space: participatory_process) }
  let!(:subcategory) { create(:subcategory, parent: category, participatory_space: participatory_process) }
  let!(:user) { create :user, :confirmed, organization: organization }
  let(:active_step_id) { component.participatory_space.active_step.id }
  let(:settings) do
    {
      menu_amendments: show_amendments,
      menu_meetings: show_meetings
    }
  end

  let(:default_step_settings) do
    {
      show_not_answered: show_not_answered,
      show_evaluating: show_evaluating,
      show_accepted: show_accepted,
      show_rejected: show_rejected,
      show_withdrawn: show_withdrawn
    }
  end

  let(:show_amendments) { true }
  let(:show_meetings) { true }
  let(:map_config) do
    {
      provider: :here,
      api_key: "foo",
      static: { url: "https://image.maps.ls.hereapi.com/mia/1.6/mapview" }
    }
  end

  before do
    allow(Decidim.config).to receive(:maps).and_return(map_config)
  end

  it "shows the map" do
    visit_component
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
    visit_component
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
    visit_component
    within ".awesome-map" do
      expect(page.body).to have_content(".awesome_map-category_#{category.id}")
      expect(page.body).to have_content(".awesome_map-category_#{subcategory.id}")
    end
  end

  context "when step settings are as default" do
    let(:show_accepted) { true }
    let(:show_evaluating) { true }
    let(:show_rejected) { false }
    let(:show_withdrawn) { false }

    before do
      component.update!(step_settings: { active_step_id => {
                          show_accepted: show_accepted,
                          show_evaluating: show_evaluating,
                          show_rejected: show_rejected,
                          show_withdrawn: show_withdrawn
                        } })
      visit_component
    end

    it "shows accepted and evaluating proposals markers" do
      sleep(4)
      expect(page.body).to have_selector("div[title='#{accepted_proposal.title["en"]}']")
      expect(page.body).to have_selector("div[title='#{evaluating_proposal.title["en"]}']")
      expect(page.body).not_to have_selector("div[title='#{rejected_proposal.title["en"]}']")
      expect(page.body).not_to have_selector("div[title='#{withdrawn_proposal.title["en"]}']")
    end
  end

  context "when rejected and withdrawn proposal can be shown" do
    let(:show_accepted) { true }
    let(:show_evaluating) { true }
    let(:show_rejected) { true }
    let(:show_withdrawn) { true }

    before do
      component.update!(step_settings: { active_step_id => {
                          show_accepted: show_accepted,
                          show_evaluating: show_evaluating,
                          show_rejected: show_rejected,
                          show_withdrawn: show_withdrawn
                        } })
      visit_component
    end

    it "shows the rejected proposal" do
      sleep(4)
      expect(page.body).to have_selector("div[title='#{rejected_proposal.title["en"]}']")
      expect(page.body).to have_selector("div[title='#{withdrawn_proposal.title["en"]}']")
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
