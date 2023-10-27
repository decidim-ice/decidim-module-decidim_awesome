# frozen_string_literal: true

require "spec_helper"

describe "Three flags", type: :system do
  include_context "with a component"
  let!(:organization) { create :organization }
  let(:manifest) { :three_flags }
  let!(:component) { create :proposal_component, :with_votes_enabled, organization: organization, settings: { awesome_voting_manifest: manifest, proposal_vote_abstain: proposal_vote_abstain } }
  let!(:proposals) { create_list(:proposal, 3, component: component) }
  let!(:proposal) { Decidim::Proposals::Proposal.find_by(component: component) }
  let(:proposal_title) { translated(proposal.title) }
  let(:user) { create :user, :confirmed, organization: organization }
  let(:proposal_vote_abstain) { true }

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

      context "when proposal has no votes" do
        it "shows 0 votes" do
          click_to_vote
          expect(page).to have_selector("p.vote-count[data-id=\"#{proposal.id}\"][data-weight=\"1\"]", text: "0")
          expect(page).to have_selector("p.vote-count[data-id=\"#{proposal.id}\"][data-weight=\"2\"]", text: "0")
          expect(page).to have_selector("p.vote-count[data-id=\"#{proposal.id}\"][data-weight=\"3\"]", text: "0")
        end
      end

      context "when user votes" do
        before do
          click_to_vote
        end

        context "when user didn't vote" do
          it "doesn't show link 'Change my vote'" do
            expect(page).not_to have_content("Change my vote")
          end

          it "allows the user to click on the voting button, with all voting blocks having no opacity" do
            expect(page).to have_selector(".abstain-button:not(.non-clickable)")
            expect(page).to have_selector("#vote-proposal-#{proposal.id}-1 a:not(.non-clickable)")
            expect(page).to have_selector("#vote-proposal-#{proposal.id}-2 a:not(.non-clickable)")
            expect(page).to have_selector("#vote-proposal-#{proposal.id}-3 a:not(.non-clickable)")
          end
        end

        context "when user voted" do
          before do
            find("#vote-proposal-#{proposal.id}-3 a").click
          end

          it "shows vote" do
            expect(page).to have_selector("p.vote-count[data-id=\"#{proposal.id}\"][data-weight=\"3\"]", text: "1")
          end

          it "shows link 'Change my vote'" do
            expect(page).to have_content("Change my vote")
          end

          it "can delete vote" do
            click_link "Change my vote"
            sleep 1
            expect(page).to have_selector("p.vote-count[data-id=\"#{proposal.id}\"][data-weight=\"3\"]", text: "0")
          end

          it "does not allow the user to click on the voting button, with blocks without vote having opacity" do
            expect(page).to have_selector(".abstain-button.non-clickable")
            expect(page).to have_selector("#vote-proposal-#{proposal.id}-1 a.non-clickable")
            expect(page).to have_selector("#vote-proposal-#{proposal.id}-2 a.non-clickable")
            expect(page).to have_selector("#vote-proposal-#{proposal.id}-3 a.non-clickable")

            expect(page).to have_selector(".abstain-button.semi-opaque")
            expect(page).to have_selector("#vote-proposal-#{proposal.id}-1 a.semi-opaque")
            expect(page).to have_selector("#vote-proposal-#{proposal.id}-2 a.semi-opaque")
            expect(page).to have_selector("#vote-proposal-#{proposal.id}-3 a.fully-opaque")
          end

          context "when abstain option enabled" do
            before do
              click_link "Abstain"
            end

            it "all voting blocks have opacity" do
              expect(page).to have_selector(".abstain-button.fully-opaque")
              expect(page).to have_selector("#vote-proposal-#{proposal.id}-1 a.fully-opaque")
              expect(page).to have_selector("#vote-proposal-#{proposal.id}-2 a.fully-opaque")
              expect(page).to have_selector("#vote-proposal-#{proposal.id}-3 a.fully-opaque")
            end

            it "all voting blocks are non-clickable" do
              expect(page).to have_selector(".abstain-button.non-clickable")
              expect(page).to have_selector("#vote-proposal-#{proposal.id}-1 a.non-clickable")
              expect(page).to have_selector("#vote-proposal-#{proposal.id}-2 a.non-clickable")
              expect(page).to have_selector("#vote-proposal-#{proposal.id}-3 a.non-clickable")
            end
          end

          context "when abstain option disabled" do
            let(:proposal_vote_abstain) { false }

            it "does not show abstain option" do
              expect(page).not_to have_content("Abstain")
            end
          end
        end
      end
    end
  end
end
