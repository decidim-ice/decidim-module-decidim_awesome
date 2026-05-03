# frozen_string_literal: true

require "spec_helper"

describe "Votes by proposal status with voting cards" do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:component) do
    create(
      :proposal_component,
      participatory_space:,
      settings: { awesome_voting_manifest: "voting_cards" }
    )
  end
  let(:accepted_state) { Decidim::Proposals::ProposalState.find_by(component:, token: "accepted") }
  let!(:accepted_proposal) { create(:proposal, component:, state: "accepted") }
  let!(:rejected_proposal) { create(:proposal, component:, state: "rejected") }

  let(:user) { create(:user, :confirmed, organization:) }
  let(:not_allowed_text) { "Voting unavailable" }

  let(:step_settings) do
    {
      votes_enabled: true,
      awesome_votes_enabled_by_status: true,
      awesome_votes_enabled_states: [accepted_state.id.to_s]
    }
  end

  before do
    component.update!(step_settings: { participatory_space.active_step.id => step_settings })
    login_as user, scope: :user
    visit_component
  end

  def vote_area_for(proposal)
    "#proposal-#{proposal.id}-vote-button"
  end

  def switch_to_grid_mode
    within ".view-layout__links" do
      click_on "Grid mode"
    end
  end

  shared_examples "voting cards status filter" do
    it "shows the blocked message instead of voting cards UI" do
      within vote_area_for(rejected_proposal) do
        expect(page).to have_content(not_allowed_text)
        expect(page).to have_no_content("Green")
      end
    end

    it "keeps voting cards UI for proposals in the allowed status" do
      within vote_area_for(accepted_proposal) do
        expect(page).to have_no_content(not_allowed_text)
        expect(page).to have_content("Green")
      end
    end
  end

  context "when in list view" do
    it_behaves_like "voting cards status filter"
  end

  context "when in grid view" do
    before { switch_to_grid_mode }

    it_behaves_like "voting cards status filter"
  end
end
