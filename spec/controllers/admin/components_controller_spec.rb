# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  module Admin
    describe ComponentsController do
      routes { Decidim::Assemblies::AdminEngine.routes }

      let(:organization) { create(:organization) }
      let(:current_user) { create(:user, :confirmed, :admin, organization:) }
      let!(:assembly) do
        create(
          :assembly,
          :published,
          organization:
        )
      end
      let(:component) do
        create(
          :proposal_component,
          participatory_space: assembly
        )
      end
      let(:manifest) { :voting_cards }

      before do
        request.env["decidim.current_organization"] = organization
        request.env["decidim.current_assembly"] = assembly
        sign_in current_user
      end

      describe "PATCH update" do
        let(:component_params) do
          {
            name_en: "Proposals component",
            settings: {
              awesome_voting_manifest: manifest
            }
          }
        end

        it "changes the voting manifest" do
          patch :update, params: { assembly_slug: assembly.slug, id: component.id, component: component_params }

          expect(component.reload.settings.awesome_voting_manifest).to eq("voting_cards")
          expect(response).to redirect_to components_path
        end

        context "when votes exist" do
          let!(:vote) { create(:proposal_vote, proposal:) }
          let(:proposal) { create(:proposal, component:) }

          it "does not change the voting manifest" do
            patch :update, params: { assembly_slug: assembly.slug, id: component.id, component: component_params }

            expect(component.reload.settings.awesome_voting_manifest).to eq("")
            expect(response).to redirect_to components_path
          end
        end
      end
    end
  end
end
