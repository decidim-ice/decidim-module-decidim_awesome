# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalLCell, type: :cell do
      subject { cell("decidim/proposals/proposal_l", proposal, context: { current_user: user }) }
      let(:manifest) { :voting_cards }
      let!(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, organization:) }
      let!(:component) { create(:proposal_component, :with_votes_enabled, organization:, settings: { awesome_voting_manifest: manifest }) }
      let!(:extra_fields) { create(:awesome_proposal_extra_fields, proposal:) }
      let(:proposal) { create(:proposal, component:) }
      let(:request) { double(host: "example.org", env: {}) }

      before do
        allow(subject).to receive(:request).and_return(request)
        Decidim::DecidimAwesome.voting_registry.register(:another_voting_system) do |voting|
          voting.show_vote_button_view = ""
          voting.show_votes_count_view = ""
        end
      end

      it "cache includes weights" do
        cache1 = subject.send(:cache_hash)
        # rubocop:disable Rails/SkipsModelValidations
        extra_fields.update_column(:vote_weight_totals, 100)
        # rubocop:enable Rails/SkipsModelValidations
        proposal.reload
        subject.instance_variable_set(:@decidim_awesome_cache_hash, nil)
        expect(cache1).not_to eq(subject.send(:cache_hash))
      end
    end
  end
end
