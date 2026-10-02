# frozen_string_literal: true

require "spec_helper"

describe "Awesome map" do
  context "when on a component page" do
    include_context "with a component"

    let(:manifest_name) { "awesome_map" }
    let(:root_taxonomy) { create(:taxonomy, organization:, name: { en: "Topics" }) }
    let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:, name: { en: "Environment" }) }
    let!(:proposal_component) do
      create(:proposal_component, :with_geocoding_enabled, participatory_space:)
    end
    let!(:proposal_states) do
      [
        create(:proposal_state, component: proposal_component, token: "accepted", title: { en: "Accepted" }),
        create(:proposal_state, component: proposal_component, token: "evaluating", title: { en: "Evaluating" })
      ]
    end
    let!(:proposal) do
      create(:proposal,
             component: proposal_component,
             proposal_state: proposal_states.first,
             title: { en: "Park renovation" },
             latitude: 40.4168,
             longitude: -3.7038,
             taxonomies: [taxonomy])
    end
    let!(:another_proposal) do
      create(:proposal,
             component: proposal_component,
             proposal_state: proposal_states.second,
             title: { en: "River cleanup" },
             latitude: 41.3874,
             longitude: 2.1686,
             taxonomies: [taxonomy])
    end
    let!(:meeting_component) { create(:meeting_component, :published, participatory_space:) }
    let!(:meeting) do
      create(:meeting, :published,
             component: meeting_component,
             title: { en: "Community workshop" },
             latitude: 42.3601,
             longitude: -71.0589,
             taxonomies: [taxonomy])
    end

    before do
      component.update!(settings: { taxonomy_filters: root_taxonomy.taxonomy_filters.ids })
      visit_component
    end

    it "shows geolocated proposals and their taxonomies on the map" do
      expect(page).to have_css(".awesome-map")

      expect(page).to have_content(taxonomy.name["en"])
      marker_icons = all(".leaflet-marker-icon")
      [proposal, another_proposal, meeting].each do |mapped_item|
        marker_icons.each do |marker|
          marker.click
          break if page.has_css?("h3.card__list-title", text: mapped_item.title["en"])
        end

        expect(page).to have_css("h3.card__list-title", text: mapped_item.title["en"])
      end
    end
  end

  context "when on the homepage" do
    let(:organization) { create(:organization) }
    let!(:content_block) do
      create(:content_block, organization:, manifest_name: :awesome_map, scope_name: :homepage)
    end
    let!(:participatory_process) { create(:participatory_process, :published, organization:) }
    let!(:proposal_component) do
      create(:proposal_component, :published, :with_geocoding_enabled, participatory_space: participatory_process)
    end
    let!(:proposal) do
      create(:proposal,
             component: proposal_component,
             title: { en: "Homepage map proposal" },
             latitude: 40.4168,
             longitude: -3.7038)
    end

    before do
      allow(Decidim.config).to receive(:maps).and_return(provider: :osm, dynamic: { tile_layer: { url: "/tile-0.png" } })
      switch_to_host(organization.host)
    end

    it "shows the map when visiting the homepage" do
      visit decidim.root_path

      within ".map-block" do
        expect(page).to have_css("#awesome-map")
        expect(page).to have_css(".awesome-map")
        find(".leaflet-marker-icon").click
        expect(page).to have_css("h3.card__list-title", text: proposal.title["en"])
      end
    end
  end
end
