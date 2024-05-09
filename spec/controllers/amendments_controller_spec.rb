# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AmendmentsController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let!(:participatory_process) { create(:participatory_process, :with_steps) }
    let(:active_step_id) { participatory_process.active_step.id }
    let(:step_settings) { { active_step_id => { amendment_creation_enabled: amendment_creation_enabled } } }
    let(:settings) { { amendments_enabled: amendments_enabled, limit_pending_amendments: limit_pending_amendments } }
    let!(:component) { create(:proposal_component, participatory_space: participatory_process, settings: settings, step_settings: step_settings) }
    let(:user) { create(:user, :confirmed, organization: component.organization) }

    let!(:amendable) { create(:proposal, component: component) }
    let!(:emendation) { create(:proposal, title: { en: "An emendation" }, component: component) }
    let!(:amendment) { create(:amendment, amendable: amendable, emendation: emendation, state: amendment_state) }
    let!(:hidden_emendation) { create(:proposal, :hidden, title: { en: "A stupid emendation" }, component: component) }
    let!(:hidden_amendment) { create(:amendment, amendable: amendable, emendation: hidden_emendation, state: "evaluating") }

    let(:amendment_state) { "evaluating" }
    let(:limit_pending_amendments) { true }
    let(:amendments_enabled) { true }
    let(:amendment_creation_enabled) { true }

    let(:params) { { id: amendment.id } }

    before do
      request.env["decidim.current_organization"] = amendable.organization
      sign_in user
    end

    shared_examples "redirects unauthorized" do |action|
      it "is not authorized" do
        get action, params: params

        expect(response).to have_http_status(:redirect)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    shared_examples "renders the template" do |action|
      it "renders the template" do
        get action, params: params

        expect(response).to render_template(action)
      end
    end

    shared_examples "redirects back with limits" do |action|
      it "redirects back" do
        get action, params: params

        expect(response).to have_http_status(:redirect)
        expect(flash[:alert]).to include("Sorry, there can only be one pending amendment at a time")
        expect(flash[:alert]).to include(emendation.title["en"])
      end
    end

    shared_examples "ignores non-proposals" do |action|
      context "when amendments are disabled" do
        let(:amendments_enabled) { false }

        it_behaves_like "redirects unauthorized", action
      end

      context "when amendment creation is disabled" do
        let(:amendment_creation_enabled) { false }

        it_behaves_like "redirects unauthorized", action
      end

      context "when not a proposals component" do
        let(:component) { create(:component, participatory_space: participatory_process, settings: settings, step_settings: step_settings) }
        let!(:amendable) { create(:dummy_resource, component: component) }
        let!(:emendation) { create(:dummy_resource, component: component) }
        let(:hidden_emendation) { nil }
        let(:hidden_amendment) { nil }

        it_behaves_like "renders the template", :new
      end
    end

    describe "GET #new" do
      it_behaves_like "ignores non-proposals", :new
      context "when limit pending amendments is disabled" do
        let(:limit_pending_amendments) { false }

        it_behaves_like "renders the template", :new
      end

      context "when limit pending amendments is enabled" do
        context "when there are no pending amendments" do
          let(:amendment_state) { "accepted" }

          it_behaves_like "renders the template", :new
        end

        context "when there are pending amendments" do
          it_behaves_like "redirects back with limits", :new
        end
      end
    end

    describe "GET #create" do
      let(:params) do
        {
          id: amendment.id,
          amendable_gid: amendable.to_sgid.to_s
        }
      end

      it_behaves_like "ignores non-proposals", :create
      context "when limit pending amendments is disabled" do
        let(:limit_pending_amendments) { false }

        it_behaves_like "renders the template", :new
      end

      context "when limit pending amendments is enabled" do
        context "when there are no pending amendments" do
          let(:amendment_state) { "accepted" }

          it_behaves_like "renders the template", :new
        end

        context "when there are pending amendments" do
          it_behaves_like "redirects back with limits", :create
        end
      end
    end

    describe "GET #edit_draft" do
      let(:amendment_state) { "draft" }
      let(:user) { amendment.amender }

      it_behaves_like "renders the template", :edit_draft
    end
  end
end
