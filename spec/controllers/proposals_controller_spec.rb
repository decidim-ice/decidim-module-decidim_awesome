# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe ProposalsController do
    routes { Decidim::Proposals::Engine.routes }

    let(:organization) { participatory_space.organization }
    let(:participatory_space) { component.participatory_space }
    let(:component) { create(:proposal_component, :with_votes_enabled, settings:) }
    let!(:proposal1) { create(:proposal, title: { :en => "m middle", :ca => "à 3", "machine_translations" => { es: "a primero" } }, component:) }
    let!(:proposal2) { create(:proposal, title: { :en => "z last", :ca => "A 2", "machine_translations" => { es: "z último" } }, component:) }
    let!(:proposal3) { create(:proposal, title: { :en => "a first", :ca => "a 1", "machine_translations" => { es: "m medio" } }, component:) }
    let(:user) { create(:user, :confirmed, organization: component.organization) }
    let!(:vote1) { create(:proposal_vote, proposal: proposal2, author: user) }
    let!(:vote2) { create(:proposal_vote, proposal: proposal3, author: user) }

    let(:params) do
      {
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
    let(:config_defaults) do
      {
        additional_proposal_sortings: additional_sortings
      }
    end
    let!(:awesome_config) { nil }
    let!(:awesome_constraint) { nil }
    let(:skip_collation_for) { "" }

    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Decidim::DecidimAwesome::Config).to receive(:defaults).and_return(config_defaults)
      allow_any_instance_of(Decidim::DecidimAwesome).to receive(:additional_proposal_sortings).and_return(additional_sortings)
      allow_any_instance_of(ActionController::TestRequest).to receive(:url).and_return("/processes/#{participatory_space.slug}/proposals")
      allow(Decidim::DecidimAwesome).to receive(:collation_for).and_call_original
      allow(Decidim::DecidimAwesome).to receive(:collation_for).with(skip_collation_for).and_return(nil)
      # rubocop:enable RSpec/AnyInstance
      request.env["decidim.current_organization"] = organization
      request.env["decidim.current_participatory_space"] = participatory_space
      request.env["decidim.current_component"] = component
      sign_in user
    end

    describe "GET index" do
      it "has order filters" do
        get(:index, params:)

        expect(response).to have_http_status(:ok)
        expect(controller.helpers.available_orders).to eq(%w(random recent supported_first supported_last az za most_voted most_endorsed most_commented most_followed with_more_authors))
        expect(controller.send(:collation)).to eq('COLLATE "en-x-icu"')
      end

      context "when collation is not found" do
        let(:skip_collation_for) { :en }

        it "has order filters" do
          get(:index, params:)
          expect(response).to have_http_status(:ok)
          expect(controller.helpers.available_orders).to eq(%w(random recent supported_first supported_last az za most_voted most_endorsed most_commented most_followed with_more_authors))
          expect(controller.send(:collation)).to be_blank
        end
      end

      context "when no additional_sortings" do
        let(:additional_sortings) { :disabled }

        it "has standard order filters" do
          get(:index, params:)

          expect(response).to have_http_status(:ok)
          expect(controller.helpers.available_orders).to eq(%w(random recent most_voted most_endorsed most_commented most_followed with_more_authors))
        end
      end

      context "when some additional_sortings" do
        let(:additional_sortings) { [:az, :supported_last] }

        it "has standard order filters" do
          get(:index, params:)

          expect(response).to have_http_status(:ok)
          expect(controller.helpers.available_orders).to eq(%w(random recent az supported_last most_voted most_endorsed most_commented most_followed with_more_authors))
        end
      end

      context "when unsupported additional_sortings" do
        let(:additional_sortings) { [:baz, :az] }

        it "has standard order filters" do
          get(:index, params:)

          expect(response).to have_http_status(:ok)
          expect(controller.helpers.available_orders).to eq(%w(random recent az most_voted most_endorsed most_commented most_followed with_more_authors))
        end
      end

      context "when awesome config exists" do
        let!(:awesome_config) { create(:awesome_config, organization:, var: :additional_proposal_sortings, value: additional_sortings) }

        it "has order filters" do
          get(:index, params:)

          expect(response).to have_http_status(:ok)
          expect(controller.helpers.available_orders).to eq(%w(random recent supported_first supported_last az za most_voted most_endorsed most_commented most_followed with_more_authors))
        end

        context "when customized" do
          let(:additional_sortings) { [:az, :za] }

          it "has order filters" do
            get(:index, params:)

            expect(response).to have_http_status(:ok)
            expect(controller.helpers.available_orders).to eq(%w(random recent az za most_voted most_endorsed most_commented most_followed with_more_authors))
          end

          context "when constrained" do
            let!(:awesome_constraint) { create(:config_constraint, awesome_config:, settings: { "participatory_space_manifest" => "participatory_processes" }) }

            it "has order filters" do
              get(:index, params:)

              expect(response).to have_http_status(:ok)
              expect(controller.helpers.available_orders).to eq(%w(random recent az za most_voted most_endorsed most_commented most_followed with_more_authors))
            end
          end
        end
      end

      context "when az order" do
        let(:params) do
          {
            component_id: component.id,
            order: "az"
          }
        end

        it "orders by az" do
          get(:index, params:)

          expect(response).to have_http_status(:ok)
          expect(assigns(:proposals).to_a).to eq([proposal3, proposal1, proposal2])
        end

        context "when other locale" do
          let(:params) do
            {
              component_id: component.id,
              order: "az",
              locale: "ca"
            }
          end

          it "orders by az" do
            get(:index, params:)

            expect(response).to have_http_status(:ok)
            expect(assigns(:proposals).to_a).to eq([proposal3, proposal2, proposal1])
          end
        end

        context "when machine_translations" do
          let(:params) do
            {
              component_id: component.id,
              order: "az",
              locale: "es"
            }
          end

          it "orders by az" do
            get(:index, params:)

            expect(response).to have_http_status(:ok)
            expect(assigns(:proposals).to_a).to eq([proposal1, proposal3, proposal2])
          end

          context "and machine_translations are missing" do
            let!(:proposal1) { create(:proposal, title: { en: "m middle", ca: "z últim" }, component:) }
            let!(:proposal2) { create(:proposal, title: { en: "z last", ca: "m mig" }, component:) }
            let!(:proposal3) { create(:proposal, title: { en: "a first", ca: "a primer" }, component:) }

            it "orders by az as per default locale" do
              get(:index, params:)

              expect(response).to have_http_status(:ok)
              expect(assigns(:proposals).to_a).to eq([proposal3, proposal1, proposal2])
            end
          end
        end
      end

      context "when za order" do
        let(:params) do
          {
            component_id: component.id,
            order: "za"
          }
        end

        it "orders by za" do
          get(:index, params:)

          expect(response).to have_http_status(:ok)
          expect(assigns(:proposals).to_a).to eq([proposal2, proposal1, proposal3])
        end

        context "when other locale" do
          let(:params) do
            {
              component_id: component.id,
              order: "za",
              locale: "ca"
            }
          end

          it "orders by za" do
            get(:index, params:)

            expect(response).to have_http_status(:ok)
            expect(assigns(:proposals).to_a).to eq([proposal1, proposal2, proposal3])
          end
        end

        context "when machine_translations" do
          let(:params) do
            {
              component_id: component.id,
              order: "za",
              locale: "es"
            }
          end

          it "orders by za" do
            get(:index, params:)

            expect(response).to have_http_status(:ok)
            expect(assigns(:proposals).to_a).to eq([proposal2, proposal3, proposal1])
          end

          context "and machine_translations are missing" do
            let!(:proposal1) { create(:proposal, title: { en: "m middle", ca: "z últim" }, component:) }
            let!(:proposal2) { create(:proposal, title: { en: "z last", ca: "m mig" }, component:) }
            let!(:proposal3) { create(:proposal, title: { en: "a first", ca: "a primer" }, component:) }

            it "orders by za as per default locale" do
              get(:index, params:)

              expect(response).to have_http_status(:ok)
              expect(assigns(:proposals).to_a).to eq([proposal2, proposal1, proposal3])
            end
          end
        end
      end

      context "when supported_first order" do
        let(:params) do
          {
            component_id: component.id,
            order: "supported_first"
          }
        end

        it "orders by supported_first" do
          get(:index, params:)

          expect(response).to have_http_status(:ok)
          expect(assigns(:proposals).to_a).to eq([proposal2, proposal3, proposal1])
        end
      end

      context "when supported_last order" do
        let(:params) do
          {
            component_id: component.id,
            order: "supported_last"
          }
        end

        it "orders by supported_last" do
          get(:index, params:)

          expect(response).to have_http_status(:ok)
          expect(assigns(:proposals).to_a).to eq([proposal1, proposal2, proposal3])
        end
      end

      context "when no votes enabled" do
        let(:component) { create(:proposal_component, :with_votes_disabled) }

        it "has order filters" do
          get(:index, params:)

          expect(response).to have_http_status(:ok)
          expect(controller.helpers.available_orders).to eq(%w(random recent az za most_endorsed most_commented most_followed with_more_authors))
        end
      end

      context "when no current_user" do
        before do
          allow(controller).to receive(:current_user).and_return(nil)
        end

        it "has order filters" do
          get(:index, params:)

          expect(response).to have_http_status(:ok)
          expect(controller.helpers.available_orders).to eq(%w(random recent az za most_voted most_endorsed most_commented most_followed with_more_authors))
        end
      end

      context "when order in session" do
        before do
          session[:order] = "supported_first"
        end

        it "orders by supported_first" do
          get(:index, params:)

          expect(response).to have_http_status(:ok)
          expect(assigns(:proposals).to_a).to eq([proposal2, proposal3, proposal1])
        end

        context "when order is nonsense" do
          let(:default_order) { "az" }

          before do
            session[:order] = "nonsense"
          end

          it "orders by default" do
            get(:index, params:)

            expect(response).to have_http_status(:ok)
            expect(assigns(:proposals).to_a).to eq([proposal3, proposal1, proposal2])
          end
        end
      end

      context "when order in params" do
        let(:params) do
          {
            component_id: component.id,
            order: "supported_last"
          }
        end

        it "orders by supported_last" do
          get(:index, params:)

          expect(response).to have_http_status(:ok)
          expect(assigns(:proposals).to_a).to eq([proposal1, proposal2, proposal3])

          get :index, params: params.except(:order)
          expect(assigns(:proposals).to_a).to eq([proposal1, proposal2, proposal3])
        end
      end
    end
  end
end
