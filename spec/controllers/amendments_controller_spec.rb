# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AmendmendsController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { participatory_space.organization }
    let(:participatory_space) { component.participatory_space }
    let(:component) { create(:proposal_component, settings: settings) }
    let!(:proposal) { create(:proposal, component: component) }
    let!(:amendment) { create(:amendment, amendable: proposal, amender: user) }
    let(:user) { create(:user, :confirmed, organization: component.organization) }
    let(:amendments_enabled) { true }
    let(:limit_pending_amendments) { false }

    let(:params) do
      {
        component_id: component.id
      }
    end
    let(:config_defaults) do
      {
        amendments_enabled: amendments_enabled,
        limit_pending_amendments: limit_pending_amendments
      }
    end

    before do
      # rubocop:enable RSpec/AnyInstance
      request.env["decidim.current_organization"] = organization
      request.env["decidim.current_participatory_space"] = participatory_space
      request.env["decidim.current_component"] = component
      sign_in user
    end

    describe "GET #new" do
      context "when amendments are enabled" do
        let(:amendments_enabled) { true }

        it "renders the form" do
          get :new, params: params
byebug
          expect(response).to be_successful
          expect(assigns(:form)).to be_a(Decidim::Amendable::CreateForm)
        end
      end

      context "when amendments are disabled" do
        let(:amendments_enabled) { false }

        it "renders 404" do
          get :new, params: params
byebug

          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
