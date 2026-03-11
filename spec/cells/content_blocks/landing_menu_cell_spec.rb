# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe ContentBlocks::LandingMenuCell, type: :cell do
    subject { cell(content_block.cell, content_block).call }

    let(:organization) { create(:organization) }
    let(:content_block) { create(:content_block, organization:, manifest_name: :awesome_landing_menu, scope_name: :homepage, settings:) }
    let(:settings) { { "menu_items" => menu_items_hash } }
    let(:menu_items_hash) { { "en" => menu_items_text } }
    let(:menu_items_text) { "About us | #hero\nProcesses | #participatory_processes" }

    controller Decidim::PagesController

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "renders navigation links" do
      expect(subject).to have_content("About us")
      expect(subject).to have_content("Processes")
      expect(subject).to have_link("About us", href: "#hero")
      expect(subject).to have_link("Processes", href: "#participatory_processes")
    end

    context "when menu_items is empty" do
      let(:menu_items_text) { "" }

      it "does not render the nav" do
        expect(subject).to have_no_css("nav")
      end
    end

    context "when menu_items has only whitespace" do
      let(:menu_items_text) { "  \n  \n  " }

      it "does not render the nav" do
        expect(subject).to have_no_css("nav")
      end
    end

    context "when item has _blank target" do
      let(:menu_items_text) { "External | https://example.com | _blank" }

      it "renders with target and rel attributes" do
        expect(subject).to have_content("External")
        expect(subject).to have_css("a[target='_blank'][rel='noopener noreferrer']", text: "External")
      end
    end

    context "when item has no target" do
      let(:menu_items_text) { "About | #hero" }

      it "renders without target attribute" do
        expect(subject).to have_link("About", href: "#hero")
        expect(subject).to have_no_css("a[target]")
      end
    end

    context "when lines are malformed" do
      let(:menu_items_text) { "No URL\n | #missing-label\nValid | #anchor\n | " }

      it "skips invalid lines and renders valid ones" do
        expect(subject).to have_content("Valid")
        expect(subject).to have_no_content("No URL")
      end
    end

    context "when URL has javascript: scheme" do
      let(:menu_items_text) { "XSS | javascript:alert(1)\nSafe | #anchor" }

      it "filters out unsafe URLs" do
        expect(subject).to have_no_content("XSS")
        expect(subject).to have_content("Safe")
      end
    end

    context "when URL has data: scheme" do
      let(:menu_items_text) { "Unsafe | data:text/html,<script>alert(1)</script>" }

      it "filters out unsafe URLs" do
        expect(subject).to have_no_css("nav")
      end
    end

    context "when URL is protocol-relative" do
      let(:menu_items_text) { "Phish | //evil.com/page\nSafe | /about" }

      it "filters out protocol-relative URLs" do
        expect(subject).to have_no_content("Phish")
        expect(subject).to have_content("Safe")
      end
    end

    context "when target is not a valid value" do
      let(:menu_items_text) { "Link | #section | _parent" }

      it "ignores invalid target" do
        expect(subject).to have_link("Link", href: "#section")
        expect(subject).to have_no_css("a[target]")
      end
    end

    describe "#menu_items" do
      let(:cell_instance) { cell(content_block.cell, content_block) }

      it "parses lines into hashes" do
        items = cell_instance.menu_items
        expect(items).to eq([
                              { label: "About us", url: "#hero", target: nil },
                              { label: "Processes", url: "#participatory_processes", target: nil }
                            ])
      end

      context "with _blank target" do
        let(:menu_items_text) { "Site | https://example.com | _blank" }

        it "includes target in hash" do
          items = cell_instance.menu_items
          expect(items).to eq([{ label: "Site", url: "https://example.com", target: "_blank" }])
        end
      end

      context "when text is blank" do
        let(:menu_items_text) { "" }

        it "returns empty array" do
          expect(cell_instance.menu_items).to eq([])
        end
      end
    end

    describe "#sticky?" do
      let(:cell_instance) { cell(content_block.cell, content_block) }

      context "when sticky is true" do
        let(:settings) { { "menu_items" => menu_items_hash, "sticky" => true } }

        it "returns true" do
          expect(cell_instance.sticky?).to be(true)
        end

        it "renders nav with sticky class" do
          expect(subject).to have_css("nav.sticky")
        end
      end

      context "when sticky is false" do
        let(:settings) { { "menu_items" => menu_items_hash, "sticky" => false } }

        it "returns false" do
          expect(cell_instance.sticky?).to be(false)
        end

        it "renders nav without sticky class" do
          expect(subject).to have_no_css("nav.sticky")
        end
      end
    end

    describe "#alignment and #justify_class" do
      let(:cell_instance) { cell(content_block.cell, content_block) }

      context "when alignment is left" do
        let(:settings) { { "menu_items" => menu_items_hash, "alignment" => "left" } }

        it "returns justify-start" do
          expect(cell_instance.justify_class).to eq("justify-start")
        end
      end

      context "when alignment is right" do
        let(:settings) { { "menu_items" => menu_items_hash, "alignment" => "right" } }

        it "returns justify-end" do
          expect(cell_instance.justify_class).to eq("justify-end")
        end
      end

      context "when alignment is center" do
        let(:settings) { { "menu_items" => menu_items_hash, "alignment" => "center" } }

        it "returns justify-center" do
          expect(cell_instance.justify_class).to eq("justify-center")
        end
      end

      context "when alignment is not set" do
        let(:settings) { { "menu_items" => menu_items_hash } }

        it "defaults to justify-center" do
          expect(cell_instance.justify_class).to eq("justify-center")
        end
      end
    end

    describe "#block_id" do
      let(:cell_instance) { cell(content_block.cell, content_block) }

      it "returns awesome-landing-menu-{id}" do
        expect(cell_instance.block_id).to eq("awesome-landing-menu-#{content_block.id}")
      end
    end
  end
end
