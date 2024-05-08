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
  let(:content) { generate_localized_title }
  let!(:user) { create(:user, :confirmed, organization:) }
  let(:images_in_proposals) { false }
  let(:images_editor) { false }
  let(:rte_enabled) { true }
  let!(:allow_images_in_proposals) { create(:awesome_config, organization:, var: :allow_images_in_proposals, value: images_in_proposals) }
  let!(:allow_images_in_editors) { create(:awesome_config, organization:, var: :allow_images_in_editors, value: images_editor) }

  before do
    organization.update(rich_text_editor_in_public_views: rte_enabled)
    login_as user, scope: :user
  end

  context "when rich text editor is enabled and images are allowed" do
    before do
      allow_images_in_editors.update(value: true)
      allow_images_in_proposals.update(value: true)
    end

    let!(:official_proposal) { create(:proposal, :with_photo, :official, body: content, component:) }
    let!(:normal_proposal) { create(:proposal, :with_photo, body: content, component:) }

    it "displays image for official proposal" do
      visit_component
      click_link_or_button translated(official_proposal.title)
      expect(page).to have_css("img[src*='city.jpeg']")
    end

    it "displays image for normal proposal" do
      visit_component
      click_link_or_button translated(normal_proposal.title)
      expect(page).to have_css("img[src*='city.jpeg']")
    end
  end

  context "when rich text editor is disabled and images are allowed only in official proposals" do
    before do
      allow_images_in_editors.update(value: false)
      allow_images_in_proposals.update(value: true)
    end

    let!(:official_proposal) { create(:proposal, :with_photo, :official, body: content, component:) }

    it "displays image for official proposal despite editor being disabled" do
      visit_component
      click_link_or_button translated(official_proposal.title)
      expect(page).to have_css("img[src*='city.jpeg']")
    end
  end

  context "when images in proposals are not allowed, despite rich text editor settings" do
    before do
      allow_images_in_editors.update(value: true)
      allow_images_in_proposals.update(value: false)
    end

    let!(:normal_proposal) { create(:proposal, :with_photo, body: content, component:) }
    let!(:official_proposal) { create(:proposal, :with_photo, :official, body: content, component:) }

    it "does not display image for normal proposal" do
      visit_component
      click_link_or_button translated(normal_proposal.title)
      expect(page).to have_css("img[src*='city.jpeg']")
    end

    it "displays image for official proposal" do
      visit_component
      click_link_or_button translated(official_proposal.title)
      expect(page).to have_css("img[src*='city.jpeg']")
    end
  end
end
