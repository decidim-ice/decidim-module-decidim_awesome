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
  let!(:allow_videos_in_editors) { create(:awesome_config, organization:, var: :allow_videos_in_editors, value: videos_editor) }
  let(:images_in_proposals) { false }
  let(:images_editor) { false }
  let(:videos_editor) { false }
  let(:rte_enabled) { false }
  let(:editor_selector) { "#proposal_body_en" }

  include_context "when managing a component as an admin"

  before do
    organization.update(rich_text_editor_in_public_views: rte_enabled)
    visit_component_admin

    within "tr[data-id='#{proposal.id}']" do
      find("button[data-controller='dropdown']").click
      click_on "Edit proposal"
    end
  end

  context "when rich text editor is enabled for participants" do
    let(:rte_enabled) { true }

    it_behaves_like "has image support"
    it_behaves_like "has video support"

    context "and images in RTE are enabled" do
      let(:images_editor) { true }

      it_behaves_like "has image support"
    end

    context "and videos in RTE are enabled" do
      let(:videos_editor) { true }

      it_behaves_like "has video support"
    end

    context "and both in RTE are enabled" do
      let(:images_editor) { true }
      let(:videos_editor) { true }

      it_behaves_like "has image support"
      it_behaves_like "has video support"
    end
  end

  context "when rich text editor is NOT enabled for participants" do
    it_behaves_like "has image support"
    it_behaves_like "has video support"

    context "and images in proposals is enabled" do
      let(:images_in_proposals) { true }

      it_behaves_like "has image support"
      it_behaves_like "has video support"
    end
  end
end
