# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalVotesCountCell, type: :cell do
      subject { cell("decidim/proposals/proposal_votes_count", proposal, context: { current_user: user }).call }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, organization:) }
      let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
      let(:manifest) { nil }
      let(:votes_trait) { :with_votes_enabled }
      let(:component) { create(:proposal_component, votes_trait, participatory_space: participatory_process, settings: { awesome_voting_manifest: manifest }) }
      let(:proposal) { create(:proposal, component:, proposal_votes_count: 5) }

      controller Decidim::Proposals::ProposalsController

      context "when no awesome voting manifest is set" do
        it "renders the standard progress bar" do
          expect(subject.to_s).to include("data-progress-bar")
          expect(subject).to have_content("5")
          expect(subject.to_s).not_to include("display: none")
        end
      end

      context "when the voting_cards manifest is active" do
        let(:manifest) { :voting_cards }

        it "renders the hidden votes count placeholder" do
          expect(subject.to_s).to include(%(id="proposal-#{proposal.id}-votes-count"))
          expect(subject.to_s).to include("display: none")
          expect(subject).to have_content("5")
          expect(subject.to_s).not_to include("data-progress-bar")
        end

        context "and votes are hidden" do
          let(:votes_trait) { :with_votes_hidden }

          it "renders nothing" do
            expect(subject.to_s).not_to include("proposal-#{proposal.id}-votes-count")
            expect(subject.to_s).not_to include("data-progress-bar")
          end
        end
      end

      context "when the manifest defines a votes count view" do
        let(:manifest) { :custom_votes_count }

        before do
          next if Decidim::DecidimAwesome.voting_registry.find(:custom_votes_count)

          Decidim::DecidimAwesome.voting_registry.register(:custom_votes_count) do |voting|
            voting.show_votes_count_view = "decidim/decidim_awesome/voting/voting_cards/show_votes_count"
          end
        end

        it "renders the custom votes count view" do
          expect(subject.to_s).to include(%(id="proposal-#{proposal.id}-votes-count"))
          expect(subject).to have_content("5")
          expect(subject.to_s).not_to include("display: none")
          expect(subject.to_s).not_to include("data-progress-bar")
        end
      end
    end
  end
end
