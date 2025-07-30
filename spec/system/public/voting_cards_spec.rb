# frozen_string_literal: true

require "spec_helper"

describe "Voting weights with cards" do
  include_context "with a component"
  let(:voting_manifest) { :voting_cards }
  let!(:component) { create(:proposal_component, :with_votes_enabled, participatory_space:, settings:) }
  let(:settings) do
    {
      vote_limit:,
      threshold_per_proposal:,
      can_accumulate_votes_beyond_threshold:,
      minimum_votes_per_user:,
      awesome_voting_manifest: voting_manifest,
      voting_cards_show_abstain: abstain,
      voting_cards_box_title: { en: box_title },
      voting_cards_instructions: { en: instructions },
      voting_cards_show_modal_help: modal_help
    }
  end
  let!(:proposals) { create_list(:proposal, 4, component:) }
  let(:proposal) { proposals.first }
  let(:proposal_title) { translated(proposal.title) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:abstain) { true }
  let(:box_title) { nil }
  let(:instructions) { nil }
  let(:modal_help) { true }
  let!(:vote_weights) { nil }
  let(:vote_limit) { 0 }
  let(:threshold_per_proposal) { 0 }
  let(:can_accumulate_votes_beyond_threshold) { false }
  let(:minimum_votes_per_user) { 0 }

  context "when the user is logged in" do
    before do
      login_as user, scope: :user
      visit_component
      find(".card__list#proposals__proposal_#{proposal.id}").click
    end

    it "has correct copies" do
      expect(page).to have_content("Vote on this proposal")
      expect(page).to have_content("ABSTAIN")
      expect(page).to have_content("Green")
      expect(page).to have_content("Red")
      expect(page).to have_content("Yellow")
      expect(page).to have_no_content("Change my vote")
      expect(page).to have_css(".vote-count[data-weight=\"1\"]", text: "0")
      expect(page).to have_css(".vote-count[data-weight=\"2\"]", text: "0")
      expect(page).to have_css(".vote-count[data-weight=\"3\"]", text: "0")

      click_on "Abstain"
      within ".vote_proposal_modal" do
        expect(page).to have_content("My vote on \"#{strip_tags(proposal_title)}\" is \"Abstain\"")
        expect(page).to have_content("Please read the election rules carefully to understand how your vote will be used by #{translated(organization.name)}")
        click_on "Cancel"
      end
      %w(Green Yellow Red).each do |color|
        within ".voting-voting_cards" do
          click_on color
        end
        within ".vote_proposal_modal" do
          expect(page).to have_content("My vote on \"#{strip_tags(proposal_title)}\" is \"#{color}\"")
          click_on "Cancel"
        end
      end
    end

    shared_examples "can vote" do |color, weight|
      it "votes with modal" do
        expect(page).to have_css(".vote-count[data-weight=\"#{weight}\"]", text: "0") if weight != "0"
        within ".voting-voting_cards" do
          click_on color
        end
        within ".vote_proposal_modal" do
          click_on "Proceed"
        end
        %w(0 1 2 3).each do |w|
          expect(page).to have_css(".vote-action.weight_#{w}.disabled")
          if w == weight
            expect(page).to have_css(".vote-count[data-weight=\"#{w}\"]", text: "1") if w != "0"
            expect(page).to have_no_css(".vote-action.weight_#{w}.dim")
            expect(page).to have_css(".vote-action.weight_#{w}.voted")
          else
            expect(page).to have_css(".vote-count[data-weight=\"#{w}\"]", text: "0") if w != "0"
            expect(page).to have_css(".vote-action.weight_#{w}.dim")
          end
        end
        expect(page).to have_content("Change my vote")
      end
    end

    it_behaves_like "can vote", "Green", "3"
    it_behaves_like "can vote", "Yellow", "2"
    it_behaves_like "can vote", "Red", "1"
    it_behaves_like "can vote", "Abstain", "0"

    context "when no abstain" do
      let(:abstain) { false }

      it "has correct copies" do
        expect(page).to have_no_content("ABSTAIN")
        expect(page).to have_content("Green")
        expect(page).to have_content("Red")
        expect(page).to have_content("Yellow")
        expect(page).to have_no_content("Change my vote")
      end
    end

    context "when no default title" do
      let(:box_title) { "-" }

      it "has no title" do
        expect(page).to have_no_content("Vote on this proposal")
      end
    end

    context "when custom title" do
      let(:box_title) { "Custom title" }

      it "has custom title" do
        expect(page).to have_content("Custom title")
      end
    end

    context "when custom modal message" do
      let(:instructions) { "Custom instructions" }

      it "has custom modal message" do
        click_on "Red"
        within ".vote_proposal_modal" do
          expect(page).to have_content("Custom instructions")
        end
      end
    end

    context "when the proposal has votes" do
      let(:modal_help) { false }
      let!(:vote_weights) do
        [
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 1),
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 1),
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 1),
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 2),
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 2),
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 3)
        ]
      end

      it "shows existing votes" do
        expect(page).to have_css(".vote-count[data-weight=\"1\"]", text: "3")
        expect(page).to have_css(".vote-count[data-weight=\"2\"]", text: "2")
        expect(page).to have_css(".vote-count[data-weight=\"3\"]", text: "1")
      end

      it "updates vote counts when the user votes" do
        click_on "Green"
        expect(page).to have_css(".vote-count[data-weight=\"3\"]", text: "2")
        click_on "Change my vote"
        click_on "Abstain"
        expect(page).to have_css(".vote-count[data-weight=\"3\"]", text: "1")
      end
    end
  end

  context "when listing proposals" do
    before do
      login_as user, scope: :user
      visit_component
    end

    let!(:vote_weights) do
      [
        create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 1),
        create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 1),
        create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 1),
        create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 2),
        create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 2),
        create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 3),
        create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 0),
        create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 0),
        create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 0),
        create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 0)
      ]
    end

    it "shows the vote count" do
      within "#proposals__proposal_#{proposal.id}" do
        expect(page).to have_content("G: 1")
        expect(page).to have_content("Y: 2")
        expect(page).to have_content("R: 3")
        expect(page).to have_content("A: 4")
      end
    end

    context "when votes are blocked" do
      let!(:component) { create(:proposal_component, :with_votes_blocked, participatory_space:, settings:) }

      it "shows the vote count and the vote button is disabled" do
        within "#proposals__proposal_#{proposal.id}" do
          expect(page).to have_content("G: 1")
        end
        click_on proposal.title["en"]
        expect(page).to have_css(".vote-count[data-weight=\"1\"]", text: "3")
        expect(page).to have_css(".vote-count[data-weight=\"2\"]", text: "2")
        expect(page).to have_css(".vote-count[data-weight=\"3\"]", text: "1")
        expect(page).to have_css(".vote-action.weight_1.disabled")
        expect(page).to have_css(".vote-action.weight_2.disabled")
        expect(page).to have_css(".vote-action.weight_3.disabled")
        expect(page).to have_css(".vote-action.weight_0.disabled")
        expect(page).to have_no_content("Change my vote")
      end
    end

    context "when votes are hidden" do
      let(:modal_help) { false }

      before do
        component.update!(step_settings: { component.participatory_space.active_step.id => { votes_hidden: true, votes_enabled: true } })
      end

      it "shows the vote count and the vote button is disabled" do
        visit_component
        within "#proposals__proposal_#{proposal.id}" do
          expect(page).to have_no_content("G: 1")
        end
        find(".card__list#proposals__proposal_#{proposal.id}").click
        expect(page).to have_no_css(".vote-count[data-weight=\"1\"]")
        expect(page).to have_no_css(".vote-count[data-weight=\"2\"]")
        expect(page).to have_no_css(".vote-count[data-weight=\"3\"]")
        expect(page).to have_no_content("Change my vote")
        click_on "Green"
        expect(page).to have_no_css(".vote-count[data-weight=\"3\"]")
        click_on "Change my vote"
        click_on "Abstain"
        expect(page).to have_no_css(".vote-count[data-weight=\"3\"]")
      end
    end

    context "when vote limit has been reached" do
      let!(:vote_weights) do
        [
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:, author: user), weight: 1),
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal: proposals[1], author: user), weight: 2),
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal: proposals[2], author: user), weight: 3)
        ]
      end
      let(:vote_limit) { 3 }

      it "shows the vote count and the vote button is disabled" do
        within "#proposals__proposal_#{proposal.id}" do
          expect(page).to have_content("G: 0")
          expect(page).to have_content("Y: 0")
          expect(page).to have_content("R: 1")
          expect(page).to have_content("A: 0")
        end
        find(".card__list#proposals__proposal_#{proposal.id}").click
        expect(page).to have_css(".vote-count[data-weight=\"1\"]", text: "1")
        expect(page).to have_css(".vote-count[data-weight=\"2\"]", text: "0")
        expect(page).to have_css(".vote-count[data-weight=\"3\"]", text: "0")
        expect(page).to have_css(".vote-action.weight_1.disabled")
        expect(page).to have_css(".vote-action.weight_2.disabled")
        expect(page).to have_css(".vote-action.weight_3.disabled")
        expect(page).to have_css(".vote-action.weight_0.disabled")
        expect(page).to have_content("Change my vote")
      end

      context "and has not voted on the proposal" do
        let!(:vote_weights) do
          [
            create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 1),
            create(:awesome_vote_weight, vote: create(:proposal_vote, proposal: proposals[1], author: user), weight: 2),
            create(:awesome_vote_weight, vote: create(:proposal_vote, proposal: proposals[2], author: user), weight: 3)
          ]
        end
        let(:vote_limit) { 2 }

        it "shows the vote count and the vote button is disabled" do
          within "#proposals__proposal_#{proposal.id}" do
            expect(page).to have_content("G: 0")
            expect(page).to have_content("Y: 0")
            expect(page).to have_content("R: 1")
            expect(page).to have_content("A: 0")
          end
          find(".card__list#proposals__proposal_#{proposal.id}").click
          expect(page).to have_css(".vote-count[data-weight=\"1\"]", text: "1")
          expect(page).to have_css(".vote-count[data-weight=\"2\"]", text: "0")
          expect(page).to have_css(".vote-count[data-weight=\"3\"]", text: "0")
          expect(page).to have_css(".vote-action.weight_1.disabled")
          expect(page).to have_css(".vote-action.weight_2.disabled")
          expect(page).to have_css(".vote-action.weight_3.disabled")
          expect(page).to have_css(".vote-action.weight_0.disabled")
          expect(page).to have_no_content("Change my vote")
          expect(page).to have_content("No votes remaining")
        end
      end
    end

    context "when proposals have a voting limit" do
      let!(:vote_weights) do
        [
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 1)
        ]
      end
      let(:threshold_per_proposal) { 1 }
      let(:modal_help) { false }

      it "shows the vote count and the vote button is disabled" do
        within "#proposals__proposal_#{proposal.id}" do
          expect(page).to have_content("G: 0")
          expect(page).to have_content("Y: 0")
          expect(page).to have_content("R: 1")
          expect(page).to have_content("A: 0")
        end
        click_on proposal.title["en"]
        expect(page).to have_css(".vote-count[data-weight=\"1\"]", text: "1")
        expect(page).to have_css(".vote-count[data-weight=\"2\"]", text: "0")
        expect(page).to have_css(".vote-count[data-weight=\"3\"]", text: "0")
        expect(page).to have_css(".vote-action.weight_1.disabled")
        expect(page).to have_css(".vote-action.weight_2.disabled")
        expect(page).to have_css(".vote-action.weight_3.disabled")
        expect(page).to have_css(".vote-action.weight_0.disabled")
        expect(page).to have_content("Vote limit reached")
      end

      context "and can accumulate more votes" do
        let(:can_accumulate_votes_beyond_threshold) { true }

        it "shows the vote count and can vote" do
          within "#proposals__proposal_#{proposal.id}" do
            expect(page).to have_content("G: 0")
            expect(page).to have_content("Y: 0")
            expect(page).to have_content("R: 1")
            expect(page).to have_content("A: 0")
          end
          find(".card__list#proposals__proposal_#{proposal.id}").click
          expect(page).to have_css(".vote-count[data-weight=\"1\"]", text: "1")
          expect(page).to have_css(".vote-count[data-weight=\"2\"]", text: "0")
          expect(page).to have_css(".vote-count[data-weight=\"3\"]", text: "0")
          expect(page).to have_no_content("Change my vote")
          click_on "Green"
          expect(page).to have_css(".vote-count[data-weight=\"3\"]", text: "1")
          click_on "Change my vote"
          click_on "Abstain"
          expect(page).to have_css(".vote-count[data-weight=\"3\"]", text: "0")
        end
      end
    end

    context "when proposals have a minimum amount of votes" do
      let(:modal_help) { false }
      let(:minimum_votes_per_user) { 2 }
      let(:proposal2) { proposals[1] }
      let!(:vote_weights) { [] }

      it "doesn't count votes unless the minimum is achieved" do
        within "#proposals__proposal_#{proposal.id}" do
          expect(page).to have_content("G: 0")
        end
        find(".card__list#proposals__proposal_#{proposal.id}").click
        expect(page).to have_css(".vote-count[data-weight=\"3\"]", text: "0")
        click_on "Green"
        expect(page).to have_css(".vote-count[data-weight=\"3\"]", text: "0")
        visit_component
        within "#proposals__proposal_#{proposal.id}" do
          expect(page).to have_content("G: 0")
        end
        within "#proposals__proposal_#{proposal2.id}" do
          expect(page).to have_content("G: 0")
        end
        find(".card__list#proposals__proposal_#{proposal2.id}").click
        expect(page).to have_css(".vote-count[data-weight=\"1\"]", text: "0")
        click_on "Red"
        expect(page).to have_css(".vote-count[data-weight=\"1\"]", text: "1")
        visit_component
        within "#proposals__proposal_#{proposal.id}" do
          expect(page).to have_content("G: 1")
        end
        find(".card__list#proposals__proposal_#{proposal.id}").click
        expect(page).to have_css(".vote-count[data-weight=\"3\"]", text: "1")
        visit_component
        within "#proposals__proposal_#{proposal.id}" do
          expect(page).to have_content("G: 1")
        end
        within "#proposals__proposal_#{proposal2.id}" do
          expect(page).to have_content("R: 1")
        end
      end
    end

    context "when proposal is rejected" do
      let(:proposal) { create(:proposal, :rejected, component:) }
      let!(:vote_weights) { [] }

      it "shows the vote count" do
        within '.filter-container [aria-labelledby="trigger-menu-state"]' do
          check "All"
          uncheck "All"
          check "Rejected"
        end
        within "#proposals__proposal_#{proposal.id}" do
          expect(page).to have_no_content("G: 0")
          expect(page).to have_no_content("Y: 0")
          expect(page).to have_no_content("R: 0")
          expect(page).to have_no_content("A: 0")
        end
      end
    end

    context "when abstain is disabled" do
      let(:abstain) { false }

      it "shows the vote count" do
        within "#proposals__proposal_#{proposal.id}" do
          expect(page).to have_content("G: 1")
          expect(page).to have_content("Y: 2")
          expect(page).to have_content("R: 3")
          expect(page).to have_no_content("A: 4")
        end
      end
    end

    context "when the user has voted" do
      let!(:vote_weights) do
        [
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:, author: user), weight: 1),
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 2),
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 2),
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 3),
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 3),
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 3),
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal: proposals[1], author: user), weight: 2),
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal: proposals[2], author: user), weight: 3),
          create(:awesome_vote_weight, vote: create(:proposal_vote, proposal: proposals[3], author: user), weight: 0)
        ]
      end

      it "shows the vote count" do
        within "#proposals__proposal_#{proposal.id}" do
          expect(page).to have_content("G: 3")
          expect(page).to have_content("Y: 2")
          expect(page).to have_content("R: 1")
          expect(page).to have_content("A: 0")
          expect(page).to have_css(".voting-weight_1")
        end
        within "#proposals__proposal_#{proposals[1].id}" do
          expect(page).to have_content("G: 0")
          expect(page).to have_content("Y: 1")
          expect(page).to have_content("R: 0")
          expect(page).to have_content("A: 0")
          expect(page).to have_css(".voting-weight_2")
        end
        within "#proposals__proposal_#{proposals[2].id}" do
          expect(page).to have_content("G: 1")
          expect(page).to have_content("Y: 0")
          expect(page).to have_content("R: 0")
          expect(page).to have_content("A: 0")
          expect(page).to have_css(".voting-weight_3")
        end
        within "#proposals__proposal_#{proposals[3].id}" do
          expect(page).to have_content("G: 0")
          expect(page).to have_content("Y: 0")
          expect(page).to have_content("R: 0")
          expect(page).to have_content("A: 1")
          expect(page).to have_css(".voting-weight_0")
        end
      end

      context "when votes are blocked" do
        let!(:component) { create(:proposal_component, :with_votes_blocked, participatory_space:, settings:) }

        it "shows the vote count and the vote button is disabled" do
          within "#proposals__proposal_#{proposal.id}" do
            expect(page).to have_content("G: 3")
          end
          click_on proposal.title["en"]
          expect(page).to have_css(".vote-count[data-weight=\"1\"]", text: "1")
          expect(page).to have_css(".vote-count[data-weight=\"2\"]", text: "2")
          expect(page).to have_css(".vote-count[data-weight=\"3\"]", text: "3")
          expect(page).to have_css(".vote-action.weight_1.disabled")
          expect(page).to have_css(".vote-action.weight_2.disabled")
          expect(page).to have_css(".vote-action.weight_3.disabled")
          expect(page).to have_no_content("Change my vote")
        end
      end
    end
  end

  context "when the user is not logged in" do
    before do
      visit_component
    end

    let!(:vote_weights) do
      [
        create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 1),
        create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 1),
        create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 1),
        create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 2),
        create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 2),
        create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 3),
        create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 0),
        create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 0),
        create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 0),
        create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:), weight: 0)
      ]
    end

    it "shows the vote count", :caching do
      within "#proposals__proposal_#{proposal.id}" do
        expect(page).to have_content("G: 1")
        expect(page).to have_content("Y: 2")
        expect(page).to have_content("R: 3")
        expect(page).to have_content("A: 4")
        # check the cached card by maintaining the number of votes and change the weight
        Decidim::DecidimAwesome::VoteWeight.find_by(weight: 3).update(weight: 1)
        visit_component
        expect(page).to have_content("G: 0")
        expect(page).to have_content("Y: 2")
        expect(page).to have_content("R: 4")
      end
    end

    context "when no voting_manifest" do
      let(:voting_manifest) { nil }

      it "has normal support button" do
        within "#proposals__proposal_#{proposal.id}" do
          expect(page).to have_no_content("G:")
          expect(page).to have_no_content("Y:")
          expect(page).to have_no_content("R:")
        end
        find(".card__list#proposals__proposal_#{proposal.id}").click

        expect(page).to have_no_css(".voting-voting_cards")
        expect(page).to have_no_content("Green")
        expect(page).to have_no_content("Yellow")
        expect(page).to have_no_content("Red")
      end
    end

    it "show the modal window on voting" do
      find(".card__list#proposals__proposal_#{proposal.id}").click
      expect(page).to have_css("#loginModal", visible: :hidden)
      click_on "Abstain"
      expect(page).to have_css("#loginModal", visible: :visible)
    end
  end
end
