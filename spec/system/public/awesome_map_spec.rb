# frozen_string_literal: true

require "spec_helper"

describe "Awesome map component" do
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
           latitude: 40.4168,
           longitude: -3.7038,
           taxonomies: [taxonomy])
  end

  before do
    component.update!(settings: { taxonomy_filters: root_taxonomy.taxonomy_filters.ids })
    visit_component
  end

  it "shows geolocated proposals and their taxonomies on the map" do
    expect(page).to have_css(".awesome-map")

    # Leaflet adds proposal markers after the map has loaded.
    expect(page).to have_css("div[title='#{proposal.title["en"]}']")
    expect(page).to have_css("div[title='#{another_proposal.title["en"]}']")
    expect(page).to have_css("div[title='#{meeting.title["en"]}']")
    expect(page).to have_content(taxonomy.name["en"])
  end
end
