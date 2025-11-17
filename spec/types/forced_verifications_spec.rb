# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/decidim_awesome/test/verification_visibility_examples"

module Decidim::DecidimAwesome
  describe LocalizedCustomFieldsType do
    include_context "with a graphql class type"
    include_context "verification visibility examples setup"
    let(:current_organization) { organization }

    let(:schema) { Decidim::Api::Schema }
    let(:query) do
      %({
        assembly(id: "#{assembly.id}") {
          components {
            id
            ...on Proposals {
              proposals {
                edges {
                  node {
                    id
                  }
                }
              }
            }
          }
        }
        assemblies {
          id
        }
        participatoryProcesses {
          id
        }
      })
    end

    it "executes successfully" do
      expect(response).to eq({
                               "assembly" => {
                                 "components" => [{ "id" => assembly_component.id.to_s,
                                                    "proposals" => {
                                                      "edges" => [{ "node" => {
                                                        "id" => assembly_proposal.id.to_s
                                                      } }]
                                                    } }]
                               },
                               "assemblies" => [{
                                 "id" => assembly.id.to_s
                               }],
                               "participatoryProcesses" => [{
                                 "id" => process.id.to_s
                               }]
                             })
    end

    it "do not include invisible resources in the export" do
      create(:config_constraint, awesome_config: sub_config, settings: { "component_manifest" => "proposals", "participatory_space_manifest" => "assemblies" })
      expect(response).to eq({
                               "assembly" => {
                                 "components" => []
                               },
                               "assemblies" => [{
                                 "id" => assembly.id.to_s
                               }],
                               "participatoryProcesses" => [{
                                 "id" => process.id.to_s
                               }]
                             })
    end

    it "does not include invisible resources in the export if restriction is on the space" do
      create(:config_constraint, awesome_config: sub_config, settings: { "participatory_space_manifest" => "assemblies" })

      expect(response).to eq({
                               "assembly" => {
                                 "components" => []
                               },
                               "assemblies" => [],
                               "participatoryProcesses" => [{
                                 "id" => process.id.to_s
                               }]
                             })
    end
  end
end
