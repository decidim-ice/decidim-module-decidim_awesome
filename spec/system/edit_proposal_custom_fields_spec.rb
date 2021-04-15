# frozen_string_literal: true

require "spec_helper"

describe "Custom proposals fields", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let!(:component) do
    create(:proposal_component,
           :with_creation_enabled,
           :with_amendments_enabled,
           manifest: manifest,
           participatory_space: participatory_process)
  end
  let!(:config) { create :awesome_config, organization: organization, var: :proposal_custom_fields, value: custom_fields }
  let(:config_helper) { create :awesome_config, organization: organization, var: :proposal_custom_field_bar }
  let!(:constraint) { create(:config_constraint, awesome_config: config_helper, settings: { "participatory_space_manifest" => "participatory_processes", "participatory_space_slug" => slug }) }
  let(:slug) { participatory_process.slug }

  let(:data) { "[#{data1},#{data2},#{data3}]" }
  let(:data1) { '{"type":"text","label":"Full Name","subtype":"text","className":"form-control","name":"text-1476748004559"}' }
  let(:data2) { '{"type":"select","label":"Occupation","className":"form-control","name":"select-1476748006618","values":[{"label":"Street Sweeper","value":"option-1","selected":true},{"label":"Moth Man","value":"option-2"},{"label":"Chemist","value":"option-3"}]}' }
  let(:data3) { '{"type":"textarea","label":"Short Bio","rows":"5","className":"form-control","name":"textarea-1476748007461"}' }

  let(:custom_fields) do
    {
      "foo" => "[#{data1},#{data2}]",
      "bar" => "[#{data3}]"
    }
  end

  before do
    login_as user, scope: :user
    visit_component
  end

  context "when editing the proposal" do
    it "has custom fields" do
      # todo
    end
  end

  context "when amending the proposal" do
    it "has custom fields" do
      # todo
    end

    context "when participatory texts" do
      it "do not have custom fields" do
        # todo
      end
    end
  end
end
