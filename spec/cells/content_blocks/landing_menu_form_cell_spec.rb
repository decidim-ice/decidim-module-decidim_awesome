# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe ContentBlocks::LandingMenuFormCell, type: :cell do
    let(:organization) { create(:organization) }
    let(:content_block) { create(:content_block, organization:, manifest_name: :awesome_landing_menu, scope_name: :homepage, settings: {}) }

    let(:form) do
      Decidim::FormBuilder.new(
        "content_block",
        content_block,
        ActionView::Base.new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, ActionController::Base.new),
        {}
      )
    end

    let(:cell_instance) do
      cell(
        "decidim/decidim_awesome/content_blocks/landing_menu_form",
        form,
        content_block: content_block
      )
    end

    controller Decidim::PagesController

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    describe "rendering" do
      subject { cell_instance.call }

      it "renders the sticky checkbox" do
        expect(subject).to have_content("Sticky")
      end

      it "renders the alignment select" do
        expect(subject).to have_content("Menu position")
      end

      it "renders the menu items textarea" do
        expect(subject).to have_content("Menu items")
      end
    end

    describe "#alignment_options" do
      it "returns 3 options" do
        expect(cell_instance.alignment_options.size).to eq(3)
      end

      it "includes left, center, and right values" do
        values = cell_instance.alignment_options.map(&:last)
        expect(values).to eq(%w(left center right))
      end

      it "has translated labels" do
        labels = cell_instance.alignment_options.map(&:first)
        expect(labels).to include("Left", "Center", "Right")
      end
    end

    describe "#available_anchors" do
      let!(:sibling_block) { create(:content_block, organization:, manifest_name: :html, scope_name: :homepage) }

      it "returns published sibling blocks" do
        anchors = cell_instance.available_anchors
        expect(anchors).not_to be_empty
        expect(anchors.first).to have_key(:label)
        expect(anchors.first).to have_key(:anchor)
      end

      it "excludes the landing menu block itself" do
        anchors = cell_instance.available_anchors
        anchor_values = anchors.map { |a| a[:anchor] }
        expect(anchor_values).not_to include(a_string_matching(/awesome_landing_menu/))
      end

      it "excludes other awesome_landing_menu blocks" do
        create(:content_block, organization:, manifest_name: :awesome_landing_menu, scope_name: :homepage)
        anchors = cell_instance.available_anchors
        anchor_values = anchors.map { |a| a[:anchor] }
        expect(anchor_values).not_to include(a_string_matching(/awesome_landing_menu/))
      end

      it "excludes unpublished blocks" do
        unpublished = create(:content_block, organization:, manifest_name: :html, scope_name: :homepage, published_at: nil)
        anchors = cell_instance.available_anchors
        anchor_values = anchors.map { |a| a[:anchor] }
        expect(anchor_values).not_to include(a_string_matching(/#{unpublished.id}/))
      end

      it "excludes blocks from another organization" do
        other_org = create(:organization)
        create(:content_block, organization: other_org, manifest_name: :html, scope_name: :homepage)
        anchor_values = cell_instance.available_anchors.map { |a| a[:anchor] }
        expect(anchor_values).not_to include(a_string_matching(/#{other_org.id}/))
      end

      context "when no sibling blocks exist" do
        before { Decidim::ContentBlock.where.not(id: content_block.id).destroy_all }

        it "returns empty array" do
          expect(cell_instance.available_anchors).to eq([])
        end
      end
    end

    describe "#content_block" do
      it "returns the content_block from options" do
        expect(cell_instance.content_block).to eq(content_block)
      end
    end

    describe "#i18n_scope" do
      it "returns correct scope" do
        expect(cell_instance.i18n_scope).to eq("decidim.decidim_awesome.content_blocks.landing_menu")
      end
    end
  end
end
