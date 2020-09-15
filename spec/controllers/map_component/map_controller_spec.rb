# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DecidimAwesome
    module MapComponent
      describe MapController, type: :controller do
        routes { Decidim::DecidimAwesome::MapComponent::Engine.routes }

        let(:user) { create(:user, :confirmed, organization: component.organization) }

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_participatory_space"] = component.participatory_space
          request.env["decidim.current_component"] = component
        end

        describe "GET show" do
          let(:component) { create(:map_component) }

          context "when everything is ok" do
            it "renders the show page" do
              get :show
              expect(response).to have_http_status(:ok)
              expect(subject).to render_template(:show)
            end
          end

          context "when no geocoder is available" do
            before do
              allow(Decidim).to receive(:geocoder).and_return(nil)
            end

            it "renders error page" do
              get :show
              expect(response).to have_http_status(:ok)
              expect(subject).to render_template(:error)
            end
          end
        end
      end
    end
  end
end
