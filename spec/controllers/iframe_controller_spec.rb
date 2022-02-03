# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module IframeComponent
    describe IframeController, type: :controller do
      routes { Decidim::DecidimAwesome::IframeComponent::Engine.routes }

      let(:user) { create(:user, :confirmed, organization: component.organization) }
      let(:component) { create(:iframe_component) }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
      end

      it_behaves_like "a blank component", Decidim::DecidimAwesome::IframeComponent::AdminEngine

      describe "GET show" do
        context "when everything is ok" do
          it "renders the show page" do
            get :show
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:show)
          end
        end
      end
    end
  end
end
