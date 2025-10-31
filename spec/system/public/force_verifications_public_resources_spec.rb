# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/verification_visibility_examples"

describe "Forced verifications on public resources" do
  let(:organization) { create(:organization, available_authorizations: [:dummy_authorization_handler]) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let(:process) { create(:participatory_process, :with_steps, title: { en: "Visible process" }, organization:) }
  let(:assembly) { create(:assembly, title: { en: "Invisible assembly" }, organization:) }
  let!(:process_component) { create(:proposal_component, participatory_space: process) }
  let!(:assembly_component) { create(:proposal_component, participatory_space: assembly) }
  let!(:process_proposal) { create(:proposal, component: process_component, title: { en: "Visible process proposal" }) }
  let!(:assembly_proposal) { create(:proposal, component: assembly_component, title: { en: "Invisible assembly proposal" }) }
  let!(:process_comment) { create(:comment, commentable: process_proposal, author: user, body: "Process comment") }
  let!(:assembly_comment) { create(:comment, commentable: assembly_proposal, author: user, body: "Assembly comment") }

  let!(:publish_assembly_action_log) { create(:action_log, organization:, resource: assembly, action: "publish", visibility: "all") }
  let!(:publish_process_action_log) { create(:action_log, organization:, resource: process, action: "publish", visibility: "all") }
  let!(:publish_process_proposal_action_log) { create(:action_log, organization:, resource: process_proposal, component: process_component, participatory_space: process, action: "publish", visibility: "all") }
  let!(:publish_assembly_proposal_action_log) { create(:action_log, organization:, resource: assembly_proposal, component: assembly_component, participatory_space: assembly, action: "publish", visibility: "all") }
  let!(:create_process_comment_action_log) { create(:action_log, organization:, resource: process_comment, component: process_comment.component, participatory_space: process, action: "create", visibility: "public-only") }
  let!(:create_assembly_comment_action_log) { create(:action_log, organization:, resource: assembly_comment, component: assembly_comment.component, participatory_space: assembly, action: "create", visibility: "public-only") }

  let(:restricted_path) { decidim_assemblies.assembly_path(assembly) }
  let!(:force_authorizations_config) do
    create(
      :awesome_config,
      organization:,
      var: :force_authorizations,
      value: force_authorizations_value
    )
  end
  let(:force_authorizations_value) do
    { "test" => { "authorization_handlers" => { "dummy_authorization_handler" => { "options" => {} } } } }
  end
  let!(:sub_config) { create(:awesome_config, organization:, var: "force_authorization_test", value: nil) }

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
