# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe ContentBlocks::LandingMenuCell, type: :cell do
    subject { cell(content_block.cell, content_block).call }

    let(:organization) { create(:organization) }
    let(:content_block) { create(:content_block, organization:, manifest_name: :awesome_landing_menu, scope_name: :homepage, settings:) }
    let(:settings) { { "menu_items" => menu_items_json } }
    let(:menu_items_json) do
      [{ "name" => { "en" => "About us" }, "url" => "#hero", "visible" => true },
       { "name" => { "en" => "Processes" }, "url" => "#participatory_processes", "visible" => true }].to_json
    end

    controller Decidim::PagesController

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "renders navigation links" do
      expect(subject).to have_link("About us", href: "#hero")
      expect(subject).to have_link("Processes", href: "#participatory_processes")
    end

    it "renders section with aria-label" do
      expect(subject).to have_css("section[aria-label]")
    end

    context "when menu_items is empty" do
      let(:menu_items_json) { "[]" }

      it "renders nothing" do
        expect(subject.text).to be_empty
      end
    end

    context "when menu_items is blank" do
      let(:menu_items_json) { "" }

      it "renders nothing" do
        expect(subject.text).to be_empty
      end
    end

    context "with invisible items" do
      let(:menu_items_json) do
        [{ "name" => { "en" => "Visible" }, "url" => "#visible", "visible" => true },
         { "name" => { "en" => "Hidden" }, "url" => "#hidden", "visible" => false }].to_json
      end

      it "filters out invisible items" do
        expect(subject).to have_content("Visible")
        expect(subject).to have_no_content("Hidden")
      end
    end

    context "with external https URL" do
      let(:menu_items_json) { [{ "name" => { "en" => "External" }, "url" => "https://example.com", "visible" => true }].to_json }

      it "renders with target _blank" do
        expect(subject).to have_css("a[target='_blank'][rel='noopener noreferrer']", text: "External")
      end
    end

    context "with anchor URL" do
      let(:menu_items_json) { [{ "name" => { "en" => "Section" }, "url" => "#section", "visible" => true }].to_json }

      it "renders without target attribute" do
        expect(subject).to have_link("Section", href: "#section")
        expect(subject).to have_no_css("a[target]", text: "Section")
      end
    end

    context "with internal path URL" do
      let(:menu_items_json) { [{ "name" => { "en" => "About" }, "url" => "/about", "visible" => true }].to_json }

      it "renders without target attribute" do
        expect(subject).to have_link("About", href: "/about")
        expect(subject).to have_no_css("a[target]", text: "About")
      end
    end

    context "with unsafe javascript URL" do
      let(:menu_items_json) do
        [{ "name" => { "en" => "XSS" }, "url" => "javascript:alert(1)", "visible" => true },
         { "name" => { "en" => "Safe" }, "url" => "#anchor", "visible" => true }].to_json
      end

      it "filters out unsafe URLs" do
        expect(subject).to have_no_content("XSS")
        expect(subject).to have_content("Safe")
      end
    end

    context "with blank name" do
      let(:menu_items_json) { [{ "name" => { "en" => "" }, "url" => "#test", "visible" => true }].to_json }

      it "filters out items with blank name" do
        expect(subject.text).to be_empty
      end
    end

    describe "#sticky?" do
      let(:cell_instance) { cell(content_block.cell, content_block) }

      context "when sticky is true" do
        let(:settings) { { "menu_items" => menu_items_json, "sticky" => true } }

        it "returns true" do
          expect(cell_instance.sticky?).to be(true)
        end
      end

      context "when sticky is false" do
        let(:settings) { { "menu_items" => menu_items_json, "sticky" => false } }

        it "returns false" do
          expect(cell_instance.sticky?).to be(false)
        end
      end
    end

    describe "#alignment" do
      let(:cell_instance) { cell(content_block.cell, content_block) }

      context "when alignment is set" do
        let(:settings) { { "menu_items" => menu_items_json, "alignment" => "left" } }

        it "returns the setting value" do
          expect(cell_instance.alignment).to eq("left")
        end
      end

      context "when alignment is not set" do
        it "defaults to center" do
          expect(cell_instance.alignment).to eq("center")
        end
      end
    end

    describe "#show_on_mobile?" do
      let(:cell_instance) { cell(content_block.cell, content_block) }

      context "when show_on_mobile is true" do
        let(:settings) { { "menu_items" => menu_items_json, "show_on_mobile" => true } }

        it "returns true" do
          expect(cell_instance.show_on_mobile?).to be(true)
        end
      end
    end

    describe "#block_id" do
      let(:cell_instance) { cell(content_block.cell, content_block) }

      it "returns awesome-landing-menu-{id}" do
        expect(cell_instance.block_id).to eq("awesome-landing-menu-#{content_block.id}")
      end
    end

    describe "#i18n_scope" do
      let(:cell_instance) { cell(content_block.cell, content_block) }

      it "returns the landing menu scope" do
        expect(cell_instance.i18n_scope).to eq("decidim.decidim_awesome.content_blocks.landing_menu")
      end
    end
  end
end
