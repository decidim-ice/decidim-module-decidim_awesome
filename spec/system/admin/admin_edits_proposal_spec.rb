# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/editor_examples"

describe "Admin edits proposals" do
  let(:manifest_name) { "proposals" }
  let(:organization) { participatory_process.organization }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:proposal) { create(:proposal, :official, component:) }
  let!(:allow_images_in_proposals) { create(:awesome_config, organization:, var: :allow_images_in_proposals, value: images_in_proposals) }
  let!(:allow_images_in_editors) { create(:awesome_config, organization:, var: :allow_images_in_editors, value: images_editor) }
  let(:images_in_proposals) { false }
  let(:images_editor) { false }
  let(:rte_enabled) { false }
  let(:editor_selector) { "#proposal_body_en" }

  include_context "when managing a component as an admin"

  before do
    organization.update(rich_text_editor_in_public_views: rte_enabled)
    visit_component_admin

    find("a.action-icon--edit-proposal").click
  end

  context "when rich text editor is enabled for participants" do
    let(:rte_enabled) { true }

    it_behaves_like "has no drag and drop", true

    context "and images in RTE are enabled" do
      let(:images_editor) { true }

      it_behaves_like "has drag and drop", true
    end
  end

  context "when rich text editor is NOT enabled for participants" do
    it_behaves_like "has no drag and drop", true

    context "and images in RTE are enabled" do
      let(:images_editor) { true }

      it_behaves_like "has drag and drop", true
    end

    context "and images in proposals is enabled" do
      let(:images_in_proposals) { true }

      it_behaves_like "has no drag and drop", true
    end
  end
end
