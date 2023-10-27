# frozen_string_literal: true

require "spec_helper"

describe "Three flags", type: :system do
  include_context "with a component"
  let!(:organization) { create :organization }
  let(:manifest) { :three_flags }
  let!(:component) { create :proposal_component, :with_votes_enabled, organization: organization, settings: { awesome_voting_manifest: manifest } }
  let!(:proposals) { create_list(:proposal, 3, component: component) }
  let!(:proposal) { Decidim::Proposals::Proposal.find_by(component: component) }
  let(:proposal_title) { translated(proposal.title) }
  let(:user) { create :user, :confirmed, organization: organization }

  def click_to_vote
    within "#proposal-#{proposal.id}-vote-button" do
      click_link "Click to vote"
    end
  end

  before do
    switch_to_host(organization.host)
  end

  context "when the user is logged in" do
    before { login_as user, scope: :user }

    describe "Voting" do
      before do
        visit_component
      end

      it "navigates to voting" do
        click_to_vote
        expect(page).to have_content("Abstain")
        expect(page).to have_content("Green")
        expect(page).to have_content("Red")
        expect(page).to have_content("Yellow")
      end

      context "when the proposal has votes" do
        let!(:weight_cache) { create(:awesome_weight_cache, proposal: proposal) }
        let!(:vote_weights) do
          [
            create_list(:awesome_vote_weight, 3, vote: create(:proposal_vote, proposal: proposal), weight: 1),
            create_list(:awesome_vote_weight, 2, vote: create(:proposal_vote, proposal: proposal), weight: 2),
            create_list(:awesome_vote_weight, 1, vote: create(:proposal_vote, proposal: proposal), weight: 3)
          ]
        end

        it "shows existing votes" do
          click_to_vote
          expect(page).to have_selector("p.vote-count[data-id=\"#{proposal.id}\"][data-weight=\"1\"]", text: "3")
          expect(page).to have_selector("p.vote-count[data-id=\"#{proposal.id}\"][data-weight=\"2\"]", text: "2")
          expect(page).to have_selector("p.vote-count[data-id=\"#{proposal.id}\"][data-weight=\"3\"]", text: "1")
        end

        it "updates vote counts when the user votes" do
          click_to_vote
          find("#vote-proposal-#{proposal.id}-3 a").click
          expect(page).to have_selector("p.vote-count[data-id=\"#{proposal.id}\"][data-weight=\"3\"]", text: "2")
        end

        it "updates vote counts when the user cancels a vote" do
          click_to_vote
          find("#vote-proposal-#{proposal.id}-3 a").click # to vote
          find("#vote-proposal-#{proposal.id}-3 a").click # to cancel vote
          expect(page).to have_selector("p.vote-count[data-id=\"#{proposal.id}\"][data-weight=\"3\"]", text: "1")
        end
      end
    end
  end
end
