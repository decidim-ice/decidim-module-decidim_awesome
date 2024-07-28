# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim::Proposals
  describe ProposalType, type: :graphql do
    include_context "with a graphql class type"
    let(:component) { create(:proposal_component) }
    let(:participatory_space) { component.participatory_space }
    let(:organization) { participatory_space.organization }
    let!(:extra_fields) { create(:awesome_proposal_extra_fields, :with_votes, proposal: model) }
    let(:custom_fields) do
      {
        foo: "[{\"type\":\"text\",\"required\":true,\"label\":\"Name\",\"name\":\"name\",\"subtype\":\"text\"},{\"type\":\"number\",\"required\":false,\"label\":\"Age\",\"name\":\"age\",\"subtype\":\"number\"}]"
      }
    end
    let!(:config) { create(:awesome_config, organization:, var: :proposal_custom_fields, value: custom_fields) }
    let!(:constraint) { create(:config_constraint, awesome_config: config, settings: { "participatory_space_manifest" => "participatory_processes", "participatory_space_slug" => slug }) }

    let(:slug) { participatory_space.slug }
    let(:xml) { "<xml><dl><dt name=\"name\">Name</dt><dd id=\"name\" name=\"name\"><div>John Barleycorn</div></dd><dt name=\"age\">Age</dt><dd id=\"age\" name=\"age\"><div>12</div></dd></dl></xml>" }
    let(:fields) do
      [
        { "type" => "text", "required" => true, "label" => "Name", "name" => "name", "subtype" => "text", "userData" => "John Barleycorn" },
        { "type" => "number", "required" => false, "label" => "Age", "name" => "age", "subtype" => "number", "userData" => "12" }
      ]
    end
    let(:translated_fields) do
      fields.map { |field| field.merge("userData" => field["userData"].gsub("John Barleycorn", "Joan Ordi")) }
    end
    let(:body) do
      {
        "en" => xml,
        "machine_translations" => {
          "ca" => xml.gsub("John Barleycorn", "Joan Ordi")
        }
      }
    end
    let(:model) { create(:proposal, component:, body:) }

    describe "id" do
      let(:query) { "{ id }" }

      it "returns the proposal's id" do
        expect(response["id"]).to eq(model.id.to_s)
      end
    end

    describe "voteCount/voteWeights" do
      let(:query) { "{ voteCount voteWeights }" }

      context "when votes are not hidden" do
        it "returns the amount of votes for this proposal" do
          expect(response["voteCount"]).to eq(5)
        end

        it "returns the weights of votes for this proposal" do
          model.update_vote_weights!
          expect(response["voteWeights"]).to eq({ "1" => 1, "2" => 1, "3" => 1, "4" => 1, "5" => 1 })
        end
      end

      context "when votes are hidden" do
        let(:component) { create(:proposal_component, :with_votes_hidden) }

        it "returns nil" do
          expect(response["voteCount"]).to be_nil
          expect(response["voteWeights"]).to be_nil
        end
      end
    end

    describe "bodyFields" do
      let(:query) do
        '{ bodyFields {
          locales
          translation(locale: "en")
          translations {
            locale
            fields
            machineTranslated
          }
        }}'
      end

      it "returns the custom fields for this proposal" do
        expect(response["bodyFields"]["locales"]).to match_array(%w(en ca))
        expect(response["bodyFields"]["translation"]).to match_array(fields)
        translations = response["bodyFields"]["translations"]
        expect(translations).to contain_exactly({
                                                  "locale" => "en",
                                                  "fields" => fields,
                                                  "machineTranslated" => false
                                                }, {
                                                  "locale" => "ca",
                                                  "fields" => translated_fields,
                                                  "machineTranslated" => true
                                                })
      end

      context "when the body is malformed" do
        let(:body) { { "en" => "Nonsense stuff" } }

        it "returns the custom fields for this proposal" do
          expect(response["bodyFields"]["locales"]).to match_array(%w(en))
          expect(response["bodyFields"]["translation"]).to contain_exactly({ "type" => "text", "required" => true, "label" => "Name", "name" => "name", "subtype" => "text" }, { "type" => "number", "required" => false, "label" => "Age", "name" => "age", "subtype" => "number" })
        end

        context "when there is a textarea in the definition" do
          let(:custom_fields) do
            {
              foo: "[{\"type\":\"text\",\"required\":true,\"label\":\"Name\",\"name\":\"name\",\"subtype\":\"text\"},{\"type\":\"textarea\",\"required\":false,\"label\":\"Description\",\"name\":\"description\",\"subtype\":\"text\"}]"
            }
          end

          it "returns the custom fields for this proposal" do
            expect(response["bodyFields"]["locales"]).to match_array(%w(en))
            expect(response["bodyFields"]["translation"]).to contain_exactly({ "type" => "text", "required" => true, "label" => "Name", "name" => "name", "subtype" => "text" }, { "type" => "textarea", "required" => false, "label" => "Description", "name" => "description", "subtype" => "text", "userData" => "Nonsense stuff" })
          end
        end
      end
    end
  end
end
