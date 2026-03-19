# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe ContentBlocks::RichTextCell, type: :cell do
    subject { block_cell.call }

    let(:organization) { create(:organization) }
    let(:content_block) { create(:content_block, organization:, manifest_name: :awesome_rich_text, scope_name: :homepage, settings:) }
    let(:settings) { { "columns" => columns_data } }
    let(:columns_data) { [{ "body" => { "en" => "<p>Hello world</p>" } }] }
    let(:block_cell) { cell(content_block.cell, content_block) }

    controller Decidim::PagesController

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    describe "#extra_classes" do
      it "returns awesome-rich-text" do
        expect(block_cell.extra_classes).to eq("awesome-rich-text")
      end
    end

    describe "#i18n_scope" do
      it "returns the correct scope" do
        expect(block_cell.i18n_scope).to eq("decidim.decidim_awesome.content_blocks.rich_text")
      end
    end

    describe "#show" do
      context "when columns are empty" do
        let(:columns_data) { [] }

        it "renders no content" do
          expect(subject).to have_no_css("section")
        end
      end

      context "when all columns have blank bodies" do
        let(:columns_data) { [{ "body" => { "en" => "" } }] }

        it "renders no content" do
          expect(subject).to have_no_css("section")
        end
      end

      context "when columns have content" do
        it "renders the block" do
          expect(subject).to have_content("Hello world")
        end
      end
    end

    describe "#block_id" do
      context "when block_id is blank" do
        let(:settings) { { "columns" => columns_data } }

        it "returns default with model id" do
          expect(block_cell.block_id).to eq("awesome-rich-text-#{content_block.id}")
        end
      end

      context "when block_id is set" do
        let(:settings) { { "block_id" => "our-team", "columns" => columns_data } }

        it "returns the sanitized value" do
          expect(block_cell.block_id).to eq("our-team")
        end
      end

      context "when block_id has special characters" do
        let(:settings) { { "block_id" => "My Block @&%!", "columns" => columns_data } }

        it "sanitizes to a valid id" do
          expect(block_cell.block_id).to eq("my-block")
        end
      end

      context "when block_id has consecutive hyphens" do
        let(:settings) { { "block_id" => "my---block", "columns" => columns_data } }

        it "collapses consecutive hyphens" do
          expect(block_cell.block_id).to eq("my-block")
        end
      end

      context "when block_id has leading and trailing hyphens" do
        let(:settings) { { "block_id" => "-my-block-", "columns" => columns_data } }

        it "strips leading and trailing hyphens" do
          expect(block_cell.block_id).to eq("my-block")
        end
      end

      context "when block_id has whitespace" do
        let(:settings) { { "block_id" => "  our team  ", "columns" => columns_data } }

        it "strips whitespace and sanitizes" do
          expect(block_cell.block_id).to eq("our-team")
        end
      end

      context "when block_id sanitizes to empty" do
        let(:settings) { { "block_id" => "@&%!", "columns" => columns_data } }

        it "falls back to default" do
          expect(block_cell.block_id).to eq("awesome-rich-text-#{content_block.id}")
        end
      end
    end

    describe "#title" do
      context "when title is not set" do
        it "returns nil" do
          expect(block_cell.title).to be_nil
        end
      end

      context "when title is set" do
        let(:settings) { { "title" => { "en" => "Our Team" }, "columns" => columns_data } }

        it "returns the translated title" do
          expect(block_cell.title).to eq("Our Team")
        end
      end

      context "when title is an empty string" do
        let(:settings) { { "title" => { "en" => "" }, "columns" => columns_data } }

        it "returns nil" do
          expect(block_cell.title).to be_nil
        end
      end
    end

    describe "#columns" do
      context "with Hash input (form params format)" do
        let(:settings) { { "columns" => { "0" => { "body" => { "en" => "<p>From hash</p>" } } } } }

        it "parses hash values as columns" do
          expect(block_cell.columns.size).to eq(1)
        end
      end

      context "with mixed empty and non-empty columns" do
        let(:columns_data) do
          [
            { "body" => { "en" => "<p>Visible</p>" } },
            { "body" => { "en" => "" } },
            { "body" => { "en" => "<p>Also visible</p>" } }
          ]
        end

        it "filters out columns with empty bodies" do
          expect(block_cell.columns.size).to eq(2)
        end
      end
    end

    describe "#column_background_color" do
      let(:column) { RichTextColumn.new(body: { "en" => "text" }, background_color: color) }

      context "when nil" do
        let(:color) { nil }

        it "returns nil" do
          expect(block_cell.column_background_color(column)).to be_nil
        end
      end

      context "when blank" do
        let(:color) { "" }

        it "returns nil" do
          expect(block_cell.column_background_color(column)).to be_nil
        end
      end

      context "with valid 3-digit hex" do
        let(:color) { "#f00" }

        it "returns the color" do
          expect(block_cell.column_background_color(column)).to eq("#f00")
        end
      end

      context "with valid 6-digit hex" do
        let(:color) { "#ff0000" }

        it "returns the color" do
          expect(block_cell.column_background_color(column)).to eq("#ff0000")
        end
      end

      context "with uppercase hex" do
        let(:color) { "#FF0000" }

        it "returns the color" do
          expect(block_cell.column_background_color(column)).to eq("#FF0000")
        end
      end

      context "without hash prefix" do
        let(:color) { "ff0000" }

        it "returns nil" do
          expect(block_cell.column_background_color(column)).to be_nil
        end
      end

      context "with wrong length" do
        let(:color) { "#ff00" }

        it "returns nil" do
          expect(block_cell.column_background_color(column)).to be_nil
        end
      end

      context "with non-hex characters" do
        let(:color) { "#gggggg" }

        it "returns nil" do
          expect(block_cell.column_background_color(column)).to be_nil
        end
      end
    end

    describe "#column_background_image" do
      context "without an image" do
        it "returns blank" do
          expect(block_cell.column_background_image(0)).to be_blank
        end
      end

      context "with an image" do
        before do
          allow(block_cell).to receive(:column_background_image).with(0).and_return("http://example.com/bg.jpg")
        end

        it "returns the URL" do
          expect(block_cell.column_background_image(0)).to be_present
        end
      end
    end

    describe "#column_styles" do
      let(:column) { RichTextColumn.new(body: { "en" => "text" }, background_color: color) }
      let(:color) { nil }

      context "with no color and no image" do
        it "returns empty string" do
          expect(block_cell.column_styles(column, 0)).to eq("")
        end
      end

      context "with only color" do
        let(:color) { "#ff0000" }

        it "includes the CSS variable for color" do
          expect(block_cell.column_styles(column, 0)).to include("--awesome-rich-text-bg: #ff0000")
        end
      end

      context "with only image" do
        before do
          allow(block_cell).to receive(:column_background_image).with(0).and_return("http://example.com/bg.jpg")
        end

        it "includes the CSS variable for image" do
          expect(block_cell.column_styles(column, 0)).to include("--awesome-rich-text-bg-image: url('http://example.com/bg.jpg')")
        end
      end

      context "with both color and image" do
        let(:color) { "#ff0000" }

        before do
          allow(block_cell).to receive(:column_background_image).with(0).and_return("http://example.com/bg.jpg")
        end

        it "includes both CSS variables" do
          expect(block_cell.column_styles(column, 0)).to include("--awesome-rich-text-bg: #ff0000")
          expect(block_cell.column_styles(column, 0)).to include("--awesome-rich-text-bg-image:")
        end
      end

      context "when URL contains special characters" do
        before do
          allow(block_cell).to receive(:column_background_image).with(0).and_return("http://example.com/bg'image).jpg")
        end

        it "escapes single quotes and parentheses" do
          result = block_cell.column_styles(column, 0)
          expect(result).to include("%27")
          expect(result).to include("%29")
        end
      end
    end

    describe "#column_placement_class" do
      let(:column) { RichTextColumn.new(body: { "en" => "text" }, background_image_placement: placement) }
      let(:placement) { "cover_center" }

      context "without background image" do
        it "returns nil" do
          expect(block_cell.column_placement_class(column, 0)).to be_nil
        end
      end

      context "with background image" do
        before do
          allow(block_cell).to receive(:column_background_image).with(0).and_return("http://example.com/bg.jpg")
        end

        %w(cover_center cover_top cover_bottom contain_center repeat).each do |pl|
          context "when placement is #{pl}" do
            let(:placement) { pl }

            it "returns the correct class" do
              expect(block_cell.column_placement_class(column, 0)).to eq("awesome-rich-text--bg-#{pl.tr("_", "-")}")
            end
          end
        end

        context "when placement is unknown" do
          let(:placement) { "unknown" }

          it "defaults to cover_center" do
            expect(block_cell.column_placement_class(column, 0)).to eq("awesome-rich-text--bg-cover-center")
          end
        end
      end
    end

    describe "#grid_class" do
      context "with 1 column" do
        it "returns nil" do
          expect(block_cell.grid_class).to be_nil
        end
      end

      (2..5).each do |count|
        context "with #{count} columns" do
          let(:columns_data) { Array.new(count) { |i| { "body" => { "en" => "<p>Col #{i}</p>" } } } }

          it "returns md:grid-cols-#{count}" do
            expect(block_cell.grid_class).to eq("md:grid-cols-#{count}")
          end
        end
      end
    end

    describe "#rendered_body" do
      let(:column) { RichTextColumn.new(body: { "en" => html }, restrict_videos: restrict_videos, restrict_links: restrict_links) }
      let(:html) { "<p>Some text</p>" }
      let(:restrict_videos) { false }
      let(:restrict_links) { false }

      context "when user is logged in" do
        before { allow(block_cell).to receive(:current_user).and_return(create(:user, organization:)) }

        let(:restrict_videos) { true }
        let(:restrict_links) { true }

        it "returns the HTML without restrictions" do
          result = block_cell.rendered_body(column)
          expect(result).not_to include("loginModal")
        end
      end

      context "when user is not logged in" do
        before { allow(block_cell).to receive(:current_user).and_return(nil) }

        context "with restrict_videos" do
          let(:restrict_videos) { true }
          let(:html) { '<p>Watch this:</p><iframe src="http://example.com/video"></iframe>' }

          it "replaces iframe with login button" do
            result = block_cell.rendered_body(column)
            expect(result).not_to include("<iframe")
            expect(result).to include("loginModal")
            expect(result).to include("Sign in to watch this video")
          end
        end

        context "with restrict_videos and video tag" do
          let(:restrict_videos) { true }
          let(:html) { '<video src="http://example.com/video.mp4"></video>' }

          it "replaces video with login button" do
            result = block_cell.rendered_body(column)
            expect(result).not_to include("<video")
            expect(result).to include("loginModal")
          end
        end

        context "with restrict_videos and disabled-iframe div" do
          let(:restrict_videos) { true }
          let(:html) { '<div class="disabled-iframe">Blocked video</div>' }

          it "replaces disabled-iframe div with login button" do
            result = block_cell.rendered_body(column)
            expect(result).not_to include("disabled-iframe")
            expect(result).to include("loginModal")
          end
        end

        context "with restrict_links" do
          let(:restrict_links) { true }
          let(:html) { '<p>Click <a href="http://example.com">here</a></p>' }

          it "removes href and adds loginModal" do
            result = block_cell.rendered_body(column)
            expect(result).not_to include("href=")
            expect(result).to include("loginModal")
            expect(result).to include("here")
          end
        end

        context "with both restrictions" do
          let(:restrict_videos) { true }
          let(:restrict_links) { true }
          let(:html) { '<iframe src="http://example.com"></iframe><a href="http://link.com">Link</a>' }

          it "applies both restrictions" do
            result = block_cell.rendered_body(column)
            expect(result).not_to include("<iframe")
            expect(result).not_to include("href=")
            expect(result).to include("loginModal")
          end
        end

        context "without restrictions" do
          let(:html) { '<iframe src="http://example.com"></iframe><a href="http://link.com">Link</a>' }

          it "returns the HTML as-is" do
            result = block_cell.rendered_body(column)
            expect(result).not_to include("loginModal")
          end
        end
      end
    end

    describe "template rendering" do
      context "when title is present" do
        let(:settings) { { "title" => { "en" => "Section Title" }, "columns" => columns_data } }

        it "renders the title in an h2" do
          expect(subject).to have_css("h2", text: "Section Title")
        end
      end

      context "when title is absent" do
        it "does not render an h2" do
          expect(subject).to have_no_css("h2")
        end
      end

      context "with a single column" do
        it "does not render a grid" do
          expect(subject).to have_no_css(".grid")
        end
      end

      context "with multiple columns" do
        let(:columns_data) do
          [
            { "body" => { "en" => "<p>First</p>" } },
            { "body" => { "en" => "<p>Second</p>" } }
          ]
        end

        it "renders a grid" do
          expect(subject).to have_css(".grid")
          expect(subject).to have_content("First")
          expect(subject).to have_content("Second")
        end
      end

      context "with per-column background color" do
        let(:columns_data) { [{ "body" => { "en" => "<p>Colored</p>" }, "background_color" => "#ff0000" }] }

        it "applies background style to the column" do
          expect(subject).to have_css("[style*='--awesome-rich-text-bg: #ff0000']")
        end
      end

      context "when block_id is set" do
        let(:settings) { { "block_id" => "our-team", "columns" => columns_data } }

        it "renders the section with the custom id" do
          expect(subject).to have_css("section#our-team")
        end
      end
    end
  end
end
