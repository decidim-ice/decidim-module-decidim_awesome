# frozen_string_literal: true

require "spec_helper"

describe "Show awesome map" do
  include_context "with a component"
  let(:manifest_name) { "awesome_map" }

  let(:root_taxonomy) { create(:taxonomy, organization:) }
  let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
  let!(:proposal_component) { create(:proposal_component, :with_amendments_enabled, :with_geocoding_enabled, participatory_space: participatory_process) }
  let!(:proposal) { create(:proposal, component: proposal_component, latitude: 40, longitude: 2, taxonomies: [taxonomy]) }
  let(:emendation) { build(:proposal, component: proposal_component, latitude: 42, longitude: 4) }
  let!(:proposal_amendment) { create(:proposal_amendment, amendable: proposal, emendation:) }
  let!(:accepted_proposal) { create(:proposal, :accepted, title: { en: "Accepted proposal" }, component: proposal_component, latitude: 40, longitude: -50) }
  let!(:evaluating_proposal) { create(:proposal, :evaluating, title: { en: "Evaluating proposal" }, component: proposal_component, latitude: 30, longitude: 45) }
  let!(:not_answered_proposal) { create(:proposal, :not_answered, title: { en: "Not answered proposal" }, component: proposal_component, latitude: 70, longitude: 6) }
  let!(:withdrawn_proposal) { create(:proposal, :withdrawn, title: { en: "Withdrawn proposal" }, component: proposal_component, latitude: 60, longitude: -30) }
  let!(:rejected_proposal) { create(:proposal, :rejected, title: { en: "Rejected proposal" }, component: proposal_component, latitude: 10, longitude: 80) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let(:active_step_id) { component.participatory_space.active_step.id }
  let(:step_settings) { nil }
  let(:settings) do
    {
      menu_amendments: show_amendments,
      menu_meetings: show_meetings
    }
  end

  let(:show_amendments) { true }
  let(:show_meetings) { true }
  let(:map_config) do
    {
      provider: :osm,
      # api_key: "foo",
      # static: { url: "https://image.maps.ls.hereapi.com/mia/1.6/mapview" }
      dynamic: {
        tile_layer: {
          url: "/tile-0.png"
        }
      }
    }
  end

  before do
    allow(Decidim.config).to receive(:maps).and_return(map_config)
    component.update!(step_settings: { active_step_id => step_settings }) if step_settings
    component.update!(settings: { taxonomy_filters: root_taxonomy.taxonomy_filters.ids })
    visit_component
  end

  it "shows the map" do
    within "[data-content]" do
      expect(page).to have_no_content("maximum complexity")
      expect(page).to have_css(".awesome-map")
      expect(page).to have_css("#awesome-map")
      errors = page.driver.browser.logs.get(:browser)

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
    within("[data-content]", visible: :all) do
      expect(page).to have_xpath("//script[contains(@src,'decidim_decidim_awesome_map')]", visible: :all)
      expect(page).to have_xpath("//script[contains(@src,'decidim_map')]", visible: :all)
    end
  end

  it "shows taxonomies and colors" do
    # To ensure the map is loaded
    sleep(1)
    within ".awesome-map" do
      expect(page.body).to have_content(".awesome_map-taxonomy_#{root_taxonomy.id}")
      expect(page.body).to have_content(".awesome_map-taxonomy_#{taxonomy.id}")
    end
  end

  it "applies the default proposal state visibility" do
    expect(page).to have_css("div[title='#{accepted_proposal.title["en"]}']")
    expect(page).to have_css("div[title='#{evaluating_proposal.title["en"]}']")
    expect(page).to have_css("div[title='#{not_answered_proposal.title["en"]}']")
    expect(page).to have_no_css("div[title='#{rejected_proposal.title["en"]}']")
    expect(page).to have_no_css("div[title='#{withdrawn_proposal.title["en"]}']")
  end

  context "when answered proposals are hidden" do
    let(:step_settings) do
      { show_answered: false, show_not_answered: true, show_withdrawn: true, show_not_withdrawn: true, show_rejected: true, show_not_rejected: true }
    end

    it "keeps only unanswered proposals from the answer filter" do
      expect(page).to have_css("div[title='#{not_answered_proposal.title["en"]}']")
      expect(page).to have_no_css("div[title='#{accepted_proposal.title["en"]}']")
      expect(page).to have_no_css("div[title='#{evaluating_proposal.title["en"]}']")
    end
  end

  context "when unanswered proposals are hidden" do
    let(:step_settings) do
      { show_answered: true, show_not_answered: false, show_withdrawn: true, show_not_withdrawn: true, show_rejected: true, show_not_rejected: true }
    end

    it "keeps answered proposals" do
      expect(page).to have_css("div[title='#{accepted_proposal.title["en"]}']")
      expect(page).to have_css("div[title='#{evaluating_proposal.title["en"]}']")
      expect(page).to have_no_css("div[title='#{not_answered_proposal.title["en"]}']")
    end
  end

  context "when withdrawn proposals are hidden" do
    let(:step_settings) do
      { show_answered: true, show_not_answered: true, show_withdrawn: false, show_not_withdrawn: true, show_rejected: true, show_not_rejected: true }
    end

    it "hides withdrawn proposals only" do
      expect(page).to have_css("div[title='#{accepted_proposal.title["en"]}']")
      expect(page).to have_no_css("div[title='#{withdrawn_proposal.title["en"]}']")
    end
  end

  context "when non-withdrawn proposals are hidden" do
    let(:step_settings) do
      { show_answered: true, show_not_answered: true, show_withdrawn: true, show_not_withdrawn: false, show_rejected: true, show_not_rejected: true }
    end

    it "keeps withdrawn proposals only from the withdrawal filter" do
      expect(page).to have_css("div[title='#{withdrawn_proposal.title["en"]}']")
      expect(page).to have_no_css("div[title='#{accepted_proposal.title["en"]}']")
    end
  end

  context "when rejected proposals are hidden" do
    let(:step_settings) do
      { show_answered: true, show_not_answered: true, show_withdrawn: true, show_not_withdrawn: true, show_rejected: false, show_not_rejected: true }
    end

    it "hides rejected proposals only" do
      expect(page).to have_css("div[title='#{accepted_proposal.title["en"]}']")
      expect(page).to have_no_css("div[title='#{rejected_proposal.title["en"]}']")
    end
  end

  context "when non-rejected proposals are hidden" do
    let(:step_settings) do
      { show_answered: true, show_not_answered: true, show_withdrawn: true, show_not_withdrawn: true, show_rejected: true, show_not_rejected: false }
    end

    it "keeps rejected proposals only from the rejection filter" do
      expect(page).to have_css("div[title='#{rejected_proposal.title["en"]}']")
      expect(page).to have_no_css("div[title='#{accepted_proposal.title["en"]}']")
    end
  end

  context "when taxonomy is removed from the proposal" do
    before do
      proposal.update!(taxonomies: [])
      visit_component
    end

    it "doesn't show the taxonomy on the map menu" do
      sleep(1)
      within ".awesome-map" do
        expect(page).to have_no_content(root_taxonomy.name)
        expect(page).to have_no_content(taxonomy.name)
      end
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
