# frozen_string_literal: true

require "spec_helper"

describe "Check images in editors" do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let!(:component) do
    create(:proposal_component,
           :with_creation_enabled,
           manifest:,
           participatory_space: participatory_process)
  end
  let!(:user) { create(:user, :confirmed, organization:) }
  let(:rte_enabled) { false }
  let!(:allow_images_in_proposals) { create(:awesome_config, organization:, var: :allow_images_in_proposals, value: images_in_proposals) }
  let!(:allow_images_in_editors) { create(:awesome_config, organization:, var: :allow_images_in_editors, value: images_editor) }
  let!(:allow_videos_in_editors) { create(:awesome_config, organization:, var: :allow_videos_in_editors, value: videos_editor) }
  let(:images_in_proposals) { false }
  let(:images_editor) { false }
  let(:videos_editor) { false }
  let(:editor_selector) { "textarea#proposal_body" }
  let(:image) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }

  before do
    organization.update(rich_text_editor_in_public_views: rte_enabled)
    login_as user, scope: :user
    visit_component

    click_link_or_button "New proposal"
  end

  context "when the allow_images_in_editors is enabled" do
    let!(:images_in_proposals) { true }
    let!(:images_editor) { true }

    it "uploads the image" do
      fill_in "proposal_title", with: "This is a test proposal"
      fill_in "proposal_body", with: "This is a super test with an image"
      find(editor_selector).drop(image)
      sleep 1
      click_link_or_button "Continue"
      click_link_or_button "Send"
      click_link_or_button "Publish"
      expect(page).to have_css("img[src*='/rails/active_storage/blobss/'")
    end
  end
end
