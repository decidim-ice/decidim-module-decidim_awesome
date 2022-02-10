# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/controller_examples"

module Decidim::DecidimAwesome
  module MapComponent
    describe MapController, type: :controller do
      routes { Decidim::DecidimAwesome::MapComponent::Engine.routes }

      let(:user) { create(:user, :confirmed, organization: component.organization) }
      let(:component) { create(:map_component) }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
      end

      it_behaves_like "a blank component", Decidim::DecidimAwesome::MapComponent::AdminEngine

      describe "GET show" do
        context "when everything is ok" do
          it "renders the show page" do
            get :show
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:show)
          end
        end

        context "when no geocoder is available" do
          before do
            allow(Decidim).to receive(:maps).and_return(nil)
            # TODO: remove when 0.22 is diched
            allow(Decidim).to receive(:geocoder).and_return(nil)
          end

          it "renders error page" do
            get :show
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:error)
          end
        end
      end

      describe "map_components" do
        let(:geocoding_enabled) { true }
        let!(:meetings) { create(:component, participatory_space: component.participatory_space, manifest_name: :meetings) }
        let!(:proposals) { create(:component, participatory_space: component.participatory_space, manifest_name: :proposals, settings: { geocoding_enabled: geocoding_enabled }) }
        let!(:other) { create(:component, participatory_space: component.participatory_space, manifest_name: :dummy) }

        let(:components) do
          [meetings, proposals]
        end

        it "returns all allowed components" do
          expect(subject.send(:map_components).map(&:id)).to include(meetings.id, proposals.id)
          expect(subject.send(:map_components).map(&:id)).not_to include(other.id)
        end

        context "when a component is not published" do
          let!(:meetings) { create(:component, :unpublished, participatory_space: component.participatory_space, manifest_name: :meetings) }

          it "returns all published components" do
            expect(subject.send(:map_components).map(&:id)).to include(proposals.id)
            expect(subject.send(:map_components).map(&:id)).not_to include(other.id, meetings.id)
          end
        end

        context "when a component is not geolocated " do
          let(:geocoding_enabled) { false }

          it "returns all geolocated components" do
            expect(subject.send(:map_components).map(&:id)).to include(meetings.id)
            expect(subject.send(:map_components).map(&:id)).not_to include(other.id, proposals.id)
          end
        end
      end
    end
  end
end
