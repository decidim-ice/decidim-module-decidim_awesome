# frozen_string_literal: true

require "spec_helper"

describe "Show proposals editor", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let!(:component) do
    create(:proposal_component,
           manifest: manifest,
           participatory_space: participatory_process)
  end

  let!(:proposal) { create(:proposal, users: [user], component: component) }
  let(:proposal_title) { proposal.title.is_a?(Hash) ? translated(proposal.title) : proposal.title }

  let!(:user) { create :user, :confirmed, organization: organization }
  let(:rte_enabled) { false }
  let!(:allow_images_in_proposals) { create(:awesome_config, organization: organization, var: :allow_images_in_proposals, value: images_in_proposals) }
  let!(:allow_images_in_small_editor) { create(:awesome_config, organization: organization, var: :allow_images_in_small_editor, value: images_editor) }
  let!(:use_markdown_editor) { create(:awesome_config, organization: organization, var: :use_markdown_editor, value: markdown_enabled) }
  let!(:allow_images_in_markdown_editor) { create(:awesome_config, organization: organization, var: :allow_images_in_markdown_editor, value: markdown_images) }
  let(:images_in_proposals) { false }
  let(:images_editor) { false }
  let(:markdown_enabled) { false }
  let(:markdown_images) { false }

  before do
    organization.update(rich_text_editor_in_public_views: rte_enabled)
    login_as user, scope: :user
    visit_component

    click_link proposal_title
    click_link "Edit proposal"
  end

  shared_examples "has no drag and drop" do |rte|
    it "has no help text" do
      expect(page).not_to have_content("Add images by dragging & dropping or pasting them.")
    end

    if rte
      it "has image button" do
        expect(page).not_to have_xpath("//button[@class='ql-image']")
      end
    else
      it "has no paste event" do
        expect(page.execute_script("return typeof $._data($('#proposal_body')[0], 'events').paste")).to eq("undefined")
      end

      it "has no drop event" do
        expect(page.execute_script("return typeof $._data($('#proposal_body')[0], 'events').drop")).to eq("undefined")
      end
    end
  end

  shared_examples "has drag and drop" do |rte|
    it "has help text" do
      expect(page).to have_content("Add images by dragging & dropping or pasting them.")
    end

    if rte
      it "has image button" do
        expect(page).to have_xpath("//button[@class='ql-image']")
      end
    else
      it "has paste event" do
        expect(page.execute_script("return typeof $._data($('#proposal_body')[0], 'events').paste")).to eq("object")
      end

      it "has drop event" do
        expect(page.execute_script("return typeof $._data($('#proposal_body')[0], 'events').drop")).to eq("object")
      end
    end
  end

  shared_examples "has markdown editor" do |images|
    it "has CodeMirror class" do
      expect(page).to have_xpath("//div[@class='CodeMirror cm-s-paper CodeMirror-wrap']")
    end

    it "has toolbar" do
      expect(page).to have_xpath("//div[@class='editor-toolbar']")
    end

    if images
      it "has help text" do
        expect(page).to have_content("Add images by dragging & dropping or pasting them.")
      end
    else
      it "has no help text" do
        expect(page).not_to have_content("Add images by dragging & dropping or pasting them.")
      end
    end
  end

  shared_examples "has no markdown editor" do
    it "has CodeMirror class" do
      expect(page).not_to have_xpath("//div[@class='CodeMirror cm-s-paper CodeMirror-wrap']")
    end

    it "has toolbar" do
      expect(page).not_to have_xpath("//div[@class='editor-toolbar']")
    end
  end

  context "when rich text editor is enabled for participants" do
    let(:rte_enabled) { true }

    it_behaves_like "has no drag and drop", true

    context "and images in RTE are enabled" do
      let(:images_editor) { true }

      it_behaves_like "has drag and drop", true
    end

    context "and markdown is enabled" do
      let(:markdown_enabled) { true }

      it_behaves_like "has markdown editor"

      context "and images are enabled" do
        let(:markdown_images) { true }

        it_behaves_like "has markdown editor", true
      end
    end
  end

  context "when rich text editor is NOT enabled for participants" do
    it_behaves_like "has no drag and drop"

    context "and images in proposals is enabled" do
      let(:images_in_proposals) { true }

      it_behaves_like "has drag and drop"
    end

    context "and markdown is enabled" do
      let(:markdown_enabled) { true }

      it_behaves_like "has no markdown editor"
    end
  end
end
