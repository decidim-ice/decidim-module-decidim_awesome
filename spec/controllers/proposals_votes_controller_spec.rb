# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe ProposalVotesController, type: :controller do
    routes { Decidim::Proposals::Engine.routes }

    let(:proposal) { create(:proposal, component: component) }
    let(:user) { create(:user, :confirmed, organization: component.organization) }

    let(:params) do
      {
        proposal_id: proposal.id,
        component_id: component.id
      }
    end

    let(:manifest) { nil }
    let(:valid_manifest) { Decidim::DecidimAwesome.voting_registry.find(:three_flags) }

    before do
      allow(controller).to receive(:awesome_voting_manifest_for).and_return(manifest)
      request.env["decidim.current_organization"] = component.organization
      request.env["decidim.current_participatory_space"] = component.participatory_space
      request.env["decidim.current_component"] = component
      sign_in user
    end

    shared_examples "can vote" do
      it "allows voting" do
        expect do
          post :create, format: :js, params: params
        end.to change(ProposalVote, :count).by(1)

        expect(ProposalVote.last.author).to eq(user)
        expect(ProposalVote.last.proposal).to eq(proposal)
      end
    end

    shared_examples "no vote permissions" do
      it "doesn't allow voting" do
        expect do
          post :create, format: :js, params: params
        end.not_to change(ProposalVote, :count)

        expect(flash[:alert]).not_to be_empty
        expect(response).to have_http_status(:found)
      end
    end

    shared_examples "invalid weight" do
      it "doesn't allow voting" do
        expect do
          post :create, format: :js, params: params
        end.not_to change(ProposalVote, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    shared_examples "destroy vote" do
      it "deletes the vote" do
        expect do
          delete :destroy, format: :js, params: params
        end.to change(ProposalVote, :count).by(-1)

        expect(ProposalVote.count).to eq(0)
      end
    end

    describe "POST create" do
      context "with votes enabled" do
        let(:component) do
          create(:proposal_component, :with_votes_enabled)
        end

        it_behaves_like "can vote"

        context "when manifest" do
          let(:manifest) { valid_manifest }

          it_behaves_like "invalid weight"

          context "and params include weight" do
            let(:weight) { 1 }
            let(:params) do
              {
                proposal_id: proposal.id,
                component_id: component.id,
                weight: weight
              }
            end

            it_behaves_like "can vote"

            context "and weight is invalid" do
              let(:weight) { 4 }

              it_behaves_like "invalid weight"
            end
          end
        end
      end

      context "with votes disabled" do
        let(:component) do
          create(:proposal_component)
        end

        it_behaves_like "no vote permissions"
      end

      context "with votes enabled but votes blocked" do
        let(:component) do
          create(:proposal_component, :with_votes_blocked)
        end

        it_behaves_like "no vote permissions"
      end
    end

    describe "destroy" do
      before do
        create(:proposal_vote, proposal: proposal, author: user)
      end

      context "with vote limit enabled" do
        let(:component) do
          create(:proposal_component, :with_votes_enabled, :with_vote_limit)
        end

        it_behaves_like "destroy vote"
      end

      context "with vote limit disabled" do
        let(:component) do
          create(:proposal_component, :with_votes_enabled)
        end

        it_behaves_like "destroy vote"
      end
    end
  end
end
