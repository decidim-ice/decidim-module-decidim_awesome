# frozen_string_literal: true

require "spec_helper"

describe "Check images in editors", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let!(:component) do
    create(:proposal_component,
           :with_creation_enabled,
           manifest: manifest,
           participatory_space: participatory_process)
  end
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let(:images_editor) { false }
  let(:rte_enabled) { false }
  let!(:allow_images_in_editors) { create(:awesome_config, organization: organization, var: :allow_images_in_editors, value: images_editor) }
  let!(:official_proposal) { create(:proposal, :official, body: { en: body_with_image }, component: component) }
  let!(:normal_proposal) { create(:proposal, body: { en: body_with_image }, component: component) }

  before do
    organization.update(rich_text_editor_in_public_views: rte_enabled)
    login_as user, scope: :user
    visit_component
  end

  shared_examples "official images only" do
    it "displays image for official proposal" do
      click_link_or_button translated(official_proposal.title)
      expect(page).to have_css("img[src*='https://www.example.com/someimage.jpeg']")
    end

    it "displays no image for normal proposal" do
      click_link_or_button translated(normal_proposal.title)
      expect(page).to have_no_css("img[src*='https://www.example.com/someimage.jpeg']")
    end
  end

  shared_examples "official and normal images" do
    it "displays image for official proposal" do
      click_link_or_button translated(official_proposal.title)
      expect(page).to have_css("img[src*='https://www.example.com/someimage.jpeg']")
    end

    it "displays image for normal proposal" do
      click_link_or_button translated(normal_proposal.title)
      expect(page).to have_css("img[src*='https://www.example.com/someimage.jpeg']")
    end
  end

  context "when normal proposals" do
    let(:body_with_image) { '<p>I am a proposal with an image <img src="https://www.example.com/someimage.jpeg"></p>' }

    it_behaves_like "official images only"

    context "and images are allowed" do
      let(:images_editor) { true }

      it_behaves_like "official and normal images"
    end

    context "when RTE enabled" do
      let(:rte_enabled) { true }

      it_behaves_like "official images only"

      context "and images are allowed" do
        let(:images_editor) { true }

        it_behaves_like "official and normal images"
      end
    end
  end

  context "when custom fields proposals" do
    let!(:config) { create(:awesome_config, organization: organization, var: :proposal_custom_fields, value: custom_fields) }
    let(:config_helper) { create(:awesome_config, organization: organization, var: :proposal_custom_field_foo) }
    let(:body_with_image) { '<xml><dl><dt>Title</dt><dd id="text"><div>I am a proposal with an image</div></dd><dt>Image</dt><dd id="textarea"><div><img src="https://www.example.com/someimage.jpeg"></div></dd></dl></xml>' }
    let(:custom_fields) do
      {
        "foo" => '[{"type":"text","label":"Title","subtype":"text","className":"form-control","name":"text"},{"type":"textarea","label":"Image","subtype":"richtext","className":"form-control","name":"textarea"}]'
      }
    end

    it_behaves_like "official and normal images"
  end
end
