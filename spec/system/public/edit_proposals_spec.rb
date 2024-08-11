# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/editor_examples"

describe "Show proposals editor", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let!(:component) do
    create(:proposal_component,
           manifest: manifest,
           participatory_space: participatory_process)
  end

  let!(:proposal) { create(:proposal, users: [user], skip_injection: true, component: component) }
  let(:proposal_title) { translated(proposal.title) }

  let!(:user) { create(:user, :confirmed, organization: organization) }
  let(:rte_enabled) { false }
  let!(:allow_images_in_proposals) { create(:awesome_config, organization: organization, var: :allow_images_in_proposals, value: images_in_proposals) }
  let!(:allow_images_in_editors) { create(:awesome_config, organization: organization, var: :allow_images_in_editors, value: images_editor) }
  let!(:allow_videos_in_editors) { create(:awesome_config, organization: organization, var: :allow_videos_in_editors, value: videos_editor) }
  let(:images_in_proposals) { false }
  let(:images_editor) { false }
  let(:videos_editor) { false }
  let(:editor_selector) { "textarea#proposal_body" }
  let(:image) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }

  before do
    organization.update(rich_text_editor_in_public_views: rte_enabled)
    login_as user, scope: :user
    visit_component

    click_link_or_button proposal_title
    click_link_or_button "Edit proposal"
  end

  context "when rich text editor is enabled for participants" do
    let(:rte_enabled) { true }

    it_behaves_like "has no image support"
    it_behaves_like "has no video support"

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
    it_behaves_like "has no drag and drop"

    context "and images in proposals is enabled" do
      let(:images_in_proposals) { true }

      it_behaves_like "has drag and drop"
    end
  end
end
