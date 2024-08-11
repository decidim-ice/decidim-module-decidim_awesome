# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/box_label_editor_examples"
require "decidim/decidim_awesome/test/shared_examples/custom_fields_examples"

describe "Admin manages custom proposal fields", type: :system do
  let(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }
  let(:custom_fields) do
    {}
  end
  let(:var_name) { :proposal_custom_field }
  let!(:config) { create(:awesome_config, organization: organization, var: "#{var_name}s", value: custom_fields) }
  let(:config_helper) { create(:awesome_config, organization: organization, var: "#{var_name}_bar") }
  let!(:constraint) { create(:config_constraint, awesome_config: config_helper, settings: { "participatory_space_manifest" => "participatory_processes", component_manifest: "proposals" }) }
  let!(:another_constraint) { create(:config_constraint, awesome_config: config_helper, settings: { "participatory_space_manifest" => "participatory_processes" }) }

  let(:data) { "[#{data1},#{data2},#{data3}]" }
  let(:data1) { '{"type":"text","label":"Full Name","subtype":"text","className":"form-control","name":"text-1476748004559"}' }
  let(:data2) { '{"type":"select","label":"Occupation","className":"form-control","name":"select-1476748006618","values":[{"label":"Street Sweeper","value":"option-1","selected":true},{"label":"Moth Man","value":"option-2"},{"label":"Chemist","value":"option-3"}]}' }
  let(:data3) { '{"type":"textarea","label":"Short Bio","rows":"5","className":"form-control","name":"textarea-1476748007461"}' }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  describe "public custom fields" do
    before do
      visit decidim_admin_decidim_awesome.config_path(:proposal_custom_fields)
    end

    it_behaves_like "creates a new box", "custom fields"

    context "when updating new box" do
      let(:data) { "[#{data1},#{data3}]" }
      let(:custom_fields) do
        {
          "foo" => "[#{data1},#{data2}]",
          "bar" => "[]"
        }
      end

      it_behaves_like "edits box label inline", :fields, :foo
      it_behaves_like "updates a box"
      it_behaves_like "removes a box", "custom fields"
      it_behaves_like "adds a constraint"
      it_behaves_like "removes a constraint"
    end
  end

  describe "private custom fields" do
    let(:var_name) { :proposal_private_custom_field }

    before do
      visit decidim_admin_decidim_awesome.config_path(:proposal_private_custom_fields)
    end

    it_behaves_like "creates a new box", "private custom fields"

    context "when updating new box" do
      let(:data) { "[#{data1},#{data3}]" }
      let(:custom_fields) do
        {
          "foo" => "[#{data1},#{data2}]",
          "bar" => "[]"
        }
      end

      it_behaves_like "edits box label inline", :fields, :foo
      it_behaves_like "updates a box"
      it_behaves_like "removes a box", "private custom fields"
      it_behaves_like "adds a constraint"
      it_behaves_like "removes a constraint"
    end
  end
end
