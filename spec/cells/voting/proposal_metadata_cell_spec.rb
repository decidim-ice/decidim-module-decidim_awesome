# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DecidimAwesome
    module Voting
      describe ProposalMetadataCell, type: :cell do
        controller Decidim::Proposals::ProposalsController

        subject { cell("decidim/decidim_awesome/voting/proposal_metadata", proposal, context: { current_user: user, controller: }) }

        let(:manifest) { :voting_cards }
        let!(:organization) { create(:organization) }
        let(:user) { create(:user, :confirmed, organization:) }
        let!(:component) { create(:proposal_component, :with_votes_enabled, organization:, settings: { awesome_voting_manifest: manifest }) }
        let(:proposal) { create(:proposal, component:) }
        let!(:extra_fields) { create(:awesome_proposal_extra_fields, proposal:) }
        let!(:vote_weights) do
          [
            create_list(:awesome_vote_weight, 3, vote: create(:proposal_vote, proposal:), weight: 1),
            create_list(:awesome_vote_weight, 2, vote: create(:proposal_vote, proposal:), weight: 2),
            create_list(:awesome_vote_weight, 1, vote: create(:proposal_vote, proposal:), weight: 3)
          ]
        end
        let(:controller) { double("controller", request:) }
        let(:request) { double("request", env: { "decidim.current_organization" => organization }) }

        describe "#proposal" do
          it "returns the resource" do
            expect(subject.resource).to eq(proposal)
          end
        end

        describe "#weight_count_item" do
          it "returns the proposal items" do
            expect(subject.send(:weight_count_item)).to be_present
          end

          context "when votes are hidden" do
            before do
              component.update!(
                step_settings: {
                  component.participatory_space.active_step.id => {
                    votes_hidden: true
                  }
                }
              )
            end

            it "returns nil" do
              expect(subject.send(:weight_count_item)).to be_nil
            end
          end

          context "when proposal is rejected" do
            let!(:vote_weights) { [] }
            let(:proposal) { create(:proposal, :rejected, component:) }

            it "returns nil" do
              expect(subject.send(:weight_count_item)).to be_nil
            end
          end

          context "when proposal is withdrawn" do
            let!(:vote_weights) { [] }
            let(:proposal) { create(:proposal, :withdrawn, component:) }

            it "returns nil" do
              expect(subject.send(:weight_count_item)).to be_nil
            end
          end
        end

        describe "#current_vote" do
          context "when user has voted" do
            before do
              create(:awesome_vote_weight, vote: create(:proposal_vote, proposal:, author: user), weight: 1)
            end

            it "returns the current vote of the user for the proposal" do
              expect(subject.send(:current_vote)).to be_present
            end
          end

          context "when user has not voted" do
            it "returns nil" do
              expect(subject.send(:current_vote)).to be_nil
            end
          end
        end
      end
    end
  end
end
