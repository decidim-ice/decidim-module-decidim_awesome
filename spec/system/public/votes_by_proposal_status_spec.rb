# frozen_string_literal: true

require "spec_helper"

describe "Votes by proposal status" do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:component) { create(:proposal_component, participatory_space:) }

  let!(:accepted_proposal) { create(:proposal, component:, state: "accepted") }
  let!(:rejected_proposal) { create(:proposal, component:, state: "rejected") }
  let!(:not_answered_proposal) { create(:proposal, component:) }

  let(:user) { create(:user, :confirmed, organization:) }
  let(:not_allowed_text) { "Not accepted for voting" }
  let(:vote_button_text) { "Vote" }

  before do
    component.update!(step_settings: { participatory_space.active_step.id => step_settings })
    login_as user, scope: :user
    visit_component
  end

  def vote_area_for(proposal)
    "#proposal-#{proposal.id}-vote-button"
  end

  def votes_count_for(proposal)
    "#proposal-#{proposal.id}-votes-count"
  end

  def switch_to_grid_mode
    within ".view-layout__links" do
      click_on "Grid mode"
    end
  end

  shared_examples "status filter behaviour" do
    context "when the status filter is inactive" do
      let(:step_settings) { { votes_enabled: true, awesome_votes_enabled_by_status: false } }

      it "shows the standard vote button on every proposal" do
        within vote_area_for(accepted_proposal) do
          expect(page).to have_button(vote_button_text)
          expect(page).to have_no_content(not_allowed_text)
        end
        within vote_area_for(not_answered_proposal) do
          expect(page).to have_button(vote_button_text)
          expect(page).to have_no_content(not_allowed_text)
        end
      end
    end

    context "when the filter is enabled but no statuses are selected" do
      let(:step_settings) { { votes_enabled: true, awesome_votes_enabled_by_status: true, awesome_votes_enabled_states: [] } }

      it "falls back to standard behaviour (filter is dormant)" do
        within vote_area_for(accepted_proposal) do
          expect(page).to have_button(vote_button_text)
          expect(page).to have_no_content(not_allowed_text)
        end
      end
    end

    context "when the filter is active and only Accepted is allowed" do
      let(:step_settings) do
        {
          votes_enabled: true,
          awesome_votes_enabled_by_status: true,
          awesome_votes_enabled_states: %w(accepted)
        }
      end

      it "lets the user vote on proposals in the allowed status" do
        within vote_area_for(accepted_proposal) do
          expect(page).to have_button(vote_button_text)
          expect(page).to have_no_content(not_allowed_text)
        end
      end

      it "blocks proposals whose status is not in the list" do
        within vote_area_for(rejected_proposal) do
          expect(page).to have_content(not_allowed_text)
          expect(page).to have_no_button(vote_button_text)
        end
      end

      it "blocks proposals without an assigned status" do
        within vote_area_for(not_answered_proposal) do
          expect(page).to have_content(not_allowed_text)
          expect(page).to have_no_button(vote_button_text)
        end
      end

      it "keeps the votes counter visible for blocked proposals" do
        within votes_count_for(not_answered_proposal) do
          expect(page).to have_content("0")
        end
      end
    end

    context "when only not_answered is allowed" do
      let(:step_settings) do
        {
          votes_enabled: true,
          awesome_votes_enabled_by_status: true,
          awesome_votes_enabled_states: %w(not_answered)
        }
      end

      it "lets the user vote on proposals without an assigned status" do
        within vote_area_for(not_answered_proposal) do
          expect(page).to have_button(vote_button_text)
          expect(page).to have_no_content(not_allowed_text)
        end
      end

      it "blocks proposals with an assigned status" do
        within vote_area_for(accepted_proposal) do
          expect(page).to have_content(not_allowed_text)
          expect(page).to have_no_button(vote_button_text)
        end
        within vote_area_for(rejected_proposal) do
          expect(page).to have_content(not_allowed_text)
          expect(page).to have_no_button(vote_button_text)
        end
      end
    end

    context "when not_answered is mixed with a real status" do
      let(:step_settings) do
        {
          votes_enabled: true,
          awesome_votes_enabled_by_status: true,
          awesome_votes_enabled_states: %w(accepted not_answered)
        }
      end

      it "allows voting on both the accepted and the not-answered proposal" do
        within vote_area_for(accepted_proposal) do
          expect(page).to have_button(vote_button_text)
          expect(page).to have_no_content(not_allowed_text)
        end
        within vote_area_for(not_answered_proposal) do
          expect(page).to have_button(vote_button_text)
          expect(page).to have_no_content(not_allowed_text)
        end
      end

      it "still blocks proposals whose status is not in the list" do
        within vote_area_for(rejected_proposal) do
          expect(page).to have_content(not_allowed_text)
          expect(page).to have_no_button(vote_button_text)
        end
      end
    end

    context "when votes are blocked at the step level" do
      let(:step_settings) do
        {
          votes_enabled: true,
          votes_blocked: true,
          awesome_votes_enabled_by_status: true,
          awesome_votes_enabled_states: %w(accepted)
        }
      end

      it "disables the vote button regardless of the status filter" do
        within vote_area_for(accepted_proposal) do
          expect(page).to have_button(vote_button_text, disabled: true)
          expect(page).to have_no_content(not_allowed_text)
        end
        within vote_area_for(not_answered_proposal) do
          expect(page).to have_button(vote_button_text, disabled: true)
          expect(page).to have_no_content(not_allowed_text)
        end
      end
    end
  end

  context "when in list view" do
    it_behaves_like "status filter behaviour"
  end

  context "when in grid view" do
    before { switch_to_grid_mode }

    it_behaves_like "status filter behaviour"
  end
end
