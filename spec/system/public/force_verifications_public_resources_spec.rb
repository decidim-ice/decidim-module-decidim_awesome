# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/verification_visibility_examples"

describe "Forced verifications on public resources" do
  include_context "verification visibility examples setup"

  before do
    switch_to_host(organization.host)
  end

  context "when user is not logged in" do
    let!(:constraint) { create(:config_constraint, awesome_config: sub_config, settings: { "participatory_space_slug" => assembly.slug, "participatory_space_manifest" => "assemblies" }) }

    it_behaves_like "some resources are not visible in last activities"
  end

  context "when user is logged in" do
    before do
      login_as user, scope: :user
    end

    context "when no restrictions applied" do
      let(:force_authorizations_value) { {} }

      it_behaves_like "all resources are visible in last activities"
    end

    context "when restrictions applied to one assembly" do
      let!(:constraint) { create(:config_constraint, awesome_config: sub_config, settings: { "participatory_space_slug" => assembly.slug, "participatory_space_manifest" => "assemblies" }) }

      it_behaves_like "some resources are not visible in last activities"

      context "when there is a constraint set to 'none'" do
        let!(:another_constraint) { create(:config_constraint, awesome_config: sub_config, settings: { "participatory_space_manifest" => "none" }) }

        it_behaves_like "all resources are visible in last activities"
      end

      context "when user has granted the required authorizations" do
        let!(:authorization) { create(:authorization, :granted, user:, name: :dummy_authorization_handler, organization:) }

        it_behaves_like "all resources are visible in last activities"
      end
    end

    context "when restrictions applied to all assemblies" do
      let!(:constraint) { create(:config_constraint, awesome_config: sub_config, settings: { "participatory_space_manifest" => "assemblies" }) }

      it_behaves_like "some resources are not visible in last activities"

      context "when user has granted the required authorizations" do
        let!(:authorization) { create(:authorization, :granted, user:, name: :dummy_authorization_handler, organization:) }

        it_behaves_like "all resources are visible in last activities"
      end
    end

    context "when restrictions applied to the component" do
      let!(:constraint) { create(:config_constraint, awesome_config: sub_config, settings: { "component_manifest" => "proposals" }) }

      it_behaves_like "some resources are not visible in last activities", all_components: true

      context "and includes space manifest restriction" do
        let!(:constraint) { create(:config_constraint, awesome_config: sub_config, settings: { "participatory_space_manifest" => "assemblies", "component_manifest" => "proposals" }) }

        it_behaves_like "some resources are not visible in last activities"
      end

      context "and includes space slug restriction" do
        let!(:constraint) { create(:config_constraint, awesome_config: sub_config, settings: { "participatory_space_slug" => assembly.slug, "participatory_space_manifest" => "assemblies", "component_manifest" => "proposals" }) }

        it_behaves_like "some resources are not visible in last activities"
      end

      context "and includes component id restriction" do
        let!(:constraint) { create(:config_constraint, awesome_config: sub_config, settings: { "participatory_space_slug" => assembly.slug, "participatory_space_manifest" => "assemblies", "component_id" => assembly_component.id }) }

        it_behaves_like "some resources are not visible in last activities"
      end

      context "when user has granted the required authorizations" do
        let!(:authorization) { create(:authorization, :granted, user:, name: :dummy_authorization_handler, organization:) }

        it_behaves_like "all resources are visible in last activities"
      end
    end

    context "when restrictions applied to another component" do
      let!(:constraint) { create(:config_constraint, awesome_config: sub_config, settings: { "participatory_space_manifest" => "assemblies", "component_manifest" => "blogs" }) }

      it_behaves_like "all resources are visible in last activities"
    end
  end
end
