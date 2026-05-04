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
  let!(:accepted_proposal) { create(:proposal, component:, state: "accepted") }
  let!(:rejected_proposal) { create(:proposal, component:, state: "rejected") }
  let!(:not_answered_proposal) { create(:proposal, component:) }

  let(:user) { create(:user, :confirmed, organization:) }
  let(:not_allowed_text) { "Not accepted for voting" }

  let(:step_settings) do
    {
      votes_enabled: true,
      awesome_votes_enabled_by_status: true,
      awesome_votes_enabled_states: %w(accepted)
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

    it "shows the blocked message for proposals without an assigned status" do
      within vote_area_for(not_answered_proposal) do
        expect(page).to have_content(not_allowed_text)
        expect(page).to have_no_content("Green")
      end
    end
  end

  shared_examples "voting cards status filter with not_answered allowed" do
    it "shows voting cards UI for proposals without an assigned status" do
      within vote_area_for(not_answered_proposal) do
        expect(page).to have_no_content(not_allowed_text)
        expect(page).to have_content("Green")
      end
    end

    it "blocks proposals whose status is not in the list" do
      within vote_area_for(rejected_proposal) do
        expect(page).to have_content(not_allowed_text)
        expect(page).to have_no_content("Green")
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

  context "when not_answered is allowed" do
    let(:step_settings) do
      {
        votes_enabled: true,
        awesome_votes_enabled_by_status: true,
        awesome_votes_enabled_states: %w(not_answered)
      }
    end

    it_behaves_like "voting cards status filter with not_answered allowed"
  end
end
