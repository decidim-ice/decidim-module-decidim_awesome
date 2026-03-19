# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe ContentBlocks::RichTextFormCell, type: :cell do
    let(:organization) { create(:organization) }
    let(:cell_instance) { cell(content_block.settings_form_cell, form, content_block:) }
    let(:content_block) { create(:content_block, organization:, manifest_name: :awesome_rich_text, scope_name: :homepage, settings:) }
    let(:settings) { {} }
    let(:form) do
      Decidim::FormBuilder.new(
        "content_block",
        Decidim::Admin::ContentBlockForm.from_model(content_block),
        ActionView::Base.empty,
        {}
      )
    end

    controller Decidim::Admin::OrganizationHomepageContentBlocksController

    subject { cell(content_block.settings_form_cell, form, content_block:).call }

    describe "#form" do
      it "is an alias for model" do
        expect(cell_instance.form).to eq(cell_instance.model)
      end
    end

    describe "#i18n_scope" do
      it "returns the correct scope" do
        expect(cell_instance.i18n_scope).to eq("decidim.decidim_awesome.content_blocks.rich_text")
      end
    end

    describe "#content_block" do
      it "returns the content block from options" do
        expect(cell_instance.content_block).to eq(content_block)
      end
    end

    describe "#column_objects" do
      context "with empty settings" do
        it "returns an array with a blank column" do
          expect(cell_instance.column_objects.size).to eq(1)
          expect(cell_instance.column_objects.first).to be_a(RichTextColumn)
        end
      end

      context "with columns in settings" do
        let(:settings) { { "columns" => [{ "body" => { "en" => "A" } }, { "body" => { "en" => "B" } }] } }

        it "returns the correct number of columns" do
          expect(cell_instance.column_objects.size).to eq(2)
        end
      end
    end

    describe "#blank_column" do
      it "returns a RichTextColumn" do
        expect(cell_instance.blank_column).to be_a(RichTextColumn)
      end

      it "has expected defaults" do
        blank = cell_instance.blank_column
        expect(blank.restrict_videos).to be(false)
        expect(blank.restrict_links).to be(false)
        expect(blank.background_color).to be_nil
        expect(blank.background_image_placement).to eq("cover_center")
      end
    end

    describe "#max_columns" do
      it "returns the configured max value" do
        expect(cell_instance.max_columns).to eq(Decidim::DecidimAwesome.max_rich_text_columns)
      end
    end

    describe "#placement_options" do
      it "returns 5 options" do
        expect(cell_instance.placement_options.size).to eq(5)
      end

      it "has the correct keys" do
        keys = cell_instance.placement_options.map(&:last)
        expect(keys).to eq(%w(cover_center cover_top cover_bottom contain_center repeat))
      end

      it "has translated labels" do
        labels = cell_instance.placement_options.map(&:first)
        expect(labels).to all(be_present)
      end
    end

    describe "#default_block_id" do
      context "when content block has an existing block_id" do
        let(:settings) { { "block_id" => "custom-id" } }

        it "returns the existing block_id" do
          expect(cell_instance.default_block_id).to eq("custom-id")
        end
      end

      context "when no block_id is set" do
        it "generates a default based on existing block count" do
          expect(cell_instance.default_block_id).to match(/\Aawesome-rich-text-\d+\z/)
        end
      end
    end

    describe "rendering" do
      it "renders the block_id field" do
        expect(subject).to have_content("Internal label")
      end

      it "renders the title field" do
        expect(subject).to have_content("Block title")
      end

      it "renders per-column background settings" do
        expect(subject).to have_content("Transparent background")
        expect(subject).to have_content("Background color")
      end

      it "renders the add column button" do
        expect(subject).to have_content("Add a new column")
      end

      it "renders restrict checkboxes" do
        expect(subject).to have_content("Prevent embed videos")
        expect(subject).to have_content("Prevent links")
      end

      it "renders placement select" do
        expect(subject).to have_content("Image placement")
      end

      it "renders background image upload" do
        expect(subject).to have_content("Background image")
      end

      it "renders CSS customization hint with column-specific selectors" do
        expect(subject).to have_content("custom style")
        expect(subject).to have_content("awesome-rich-text__column:nth-child(1)")
        expect(subject).to have_content("Style for column 1")
      end
    end
  end
end
