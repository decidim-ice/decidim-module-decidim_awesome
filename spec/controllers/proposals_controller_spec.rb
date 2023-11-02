# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe ProposalsController, type: :controller do
    routes { Decidim::Proposals::Engine.routes }

    let(:component) { create(:proposal_component, :with_votes_enabled, settings: settings) }
    let!(:proposal) { create(:proposal, title: { en: "m middle" }, component: component) }
    let!(:proposal2) { create(:proposal, title: { en: "z last" }, component: component) }
    let!(:proposal3) { create(:proposal, title: { en: "a first" }, component: component) }
    let(:user) { create(:user, :confirmed, organization: component.organization) }
    let!(:vote1) { create(:proposal_vote, proposal: proposal2, author: user) }
    let!(:vote2) { create(:proposal_vote, proposal: proposal3, author: user) }

    let(:params) do
      {
        proposal_id: proposal.id,
        component_id: component.id
      }
    end
    let(:settings) do
      {
        default_sort_order: default_order
      }
    end

    let(:default_order) { "default" }

    let(:additional_sortings) { [:supported_first, :supported_last, :az, :za] }

    before do
      allow(Decidim::DecidimAwesome).to receive(:additional_proposal_sortings).and_return(additional_sortings)
      request.env["decidim.current_organization"] = component.organization
      request.env["decidim.current_participatory_space"] = component.participatory_space
      request.env["decidim.current_component"] = component
      sign_in user
    end

    describe "GET index" do
      it "has order filters" do
        get :index, params: params

        expect(response).to have_http_status(:ok)
        expect(controller.helpers.available_orders).to eq(%w(random recent supported_first supported_last az za most_voted most_endorsed most_commented most_followed with_more_authors))
      end

      context "when no additional_sortings" do
        let(:additional_sortings) { :disabled }

        it "has standard order filters" do
          get :index, params: params

          expect(response).to have_http_status(:ok)
          expect(controller.helpers.available_orders).to eq(%w(random recent most_voted most_endorsed most_commented most_followed with_more_authors))
        end
      end

      context "when some additional_sortings" do
        let(:additional_sortings) { [:az, :supported_last] }

        it "has standard order filters" do
          get :index, params: params

          expect(response).to have_http_status(:ok)
          expect(controller.helpers.available_orders).to eq(%w(random recent az supported_last most_voted most_endorsed most_commented most_followed with_more_authors))
        end
      end

      context "when strange additional_sortings" do
        let(:additional_sortings) { [:baz, :az] }

        it "has standard order filters" do
          get :index, params: params

          expect(response).to have_http_status(:ok)
          expect(controller.helpers.available_orders).to eq(%w(random recent az most_voted most_endorsed most_commented most_followed with_more_authors))
        end
      end

      context "when az order" do
        let(:params) do
          {
            proposal_id: proposal.id,
            component_id: component.id,
            order: "az"
          }
        end

        it "orders by az" do
          get :index, params: params

          expect(response).to have_http_status(:ok)
          expect(assigns(:proposals).to_a).to eq([proposal3, proposal, proposal2])
        end
      end

      context "when za order" do
        let(:params) do
          {
            proposal_id: proposal.id,
            component_id: component.id,
            order: "za"
          }
        end

        it "orders by za" do
          get :index, params: params

          expect(response).to have_http_status(:ok)
          expect(assigns(:proposals).to_a).to eq([proposal2, proposal, proposal3])
        end
      end

      context "when supported_first order" do
        let(:params) do
          {
            proposal_id: proposal.id,
            component_id: component.id,
            order: "supported_first"
          }
        end

        it "orders by supported_first" do
          get :index, params: params

          expect(response).to have_http_status(:ok)
          expect(assigns(:proposals).to_a).to eq([proposal2, proposal3, proposal])
        end
      end

      context "when supported_last order" do
        let(:params) do
          {
            proposal_id: proposal.id,
            component_id: component.id,
            order: "supported_last"
          }
        end

        it "orders by supported_last" do
          get :index, params: params

          expect(response).to have_http_status(:ok)
          expect(assigns(:proposals).to_a).to eq([proposal, proposal2, proposal3])
        end
      end

      context "when no votes enabled" do
        let(:component) { create(:proposal_component, :with_votes_disabled) }

        it "has order filters" do
          get :index, params: params

          expect(response).to have_http_status(:ok)
          expect(controller.helpers.available_orders).to eq(%w(random recent az za most_endorsed most_commented most_followed with_more_authors))
        end
      end

      context "when no current_user" do
        before do
          allow(controller).to receive(:current_user).and_return(nil)
        end

        it "has order filters" do
          get :index, params: params

          expect(response).to have_http_status(:ok)
          expect(controller.helpers.available_orders).to eq(%w(random recent az za most_voted most_endorsed most_commented most_followed with_more_authors))
        end
      end

      context "when order in session" do
        before do
          session[:order] = "supported_first"
        end

        it "orders by supported_first" do
          get :index, params: params

          expect(response).to have_http_status(:ok)
          expect(assigns(:proposals).to_a).to eq([proposal2, proposal3, proposal])
        end

        context "when order is nonsense" do
          let(:default_order) { "az" }

          before do
            session[:order] = "nonsense"
          end

          it "orders by default" do
            get :index, params: params

            expect(response).to have_http_status(:ok)
            expect(assigns(:proposals).to_a).to eq([proposal3, proposal, proposal2])
          end
        end
      end

      context "when order in params" do
        let(:params) do
          {
            proposal_id: proposal.id,
            component_id: component.id,
            order: "supported_last"
          }
        end

        it "orders by supported_last" do
          get :index, params: params

          expect(response).to have_http_status(:ok)
          expect(assigns(:proposals).to_a).to eq([proposal, proposal2, proposal3])

          get :index, params: params.except(:order)
          expect(assigns(:proposals).to_a).to eq([proposal, proposal2, proposal3])
        end
      end
    end
  end
end
