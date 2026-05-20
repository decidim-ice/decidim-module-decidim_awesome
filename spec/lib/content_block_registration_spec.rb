# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DecidimAwesome do
    let(:manifest) { Decidim.content_blocks.for(:homepage).find { |cb| cb.name == :awesome_processes } }

    it "registers :awesome_processes for :homepage scope" do
      expect(manifest).to be_present
    end

    it "has correct cell path" do
      expect(manifest.cell).to eq("decidim/decidim_awesome/content_blocks/awesome_processes")
    end

    it "has correct settings_form_cell path" do
      expect(manifest.settings_form_cell).to eq("decidim/decidim_awesome/content_blocks/awesome_processes_form")
    end

    it "has correct public_name_key" do
      expect(manifest.public_name_key).to eq("decidim.decidim_awesome.content_blocks.awesome_processes.name")
    end

    describe "settings attributes" do
      let(:settings_schema) { manifest.settings }

      it "defines :title setting as translated text" do
        attr = settings_schema.attributes[:title]
        expect(attr).to be_present
        expect(attr.type).to eq(:text)
        expect(attr.translated).to be(true)
      end

      it "defines :max_results setting with default 6" do
        attr = settings_schema.attributes[:max_results]
        expect(attr).to be_present
        expect(attr.type).to eq(:integer)
        expect(attr.default).to eq(6)
      end

      it "defines :process_type setting as enum with correct choices" do
        attr = settings_schema.attributes[:process_type]
        expect(attr).to be_present
        expect(attr.type).to eq(:enum)
        expect(attr.build_choices).to match_array(%w(all processes groups))
      end

      it "defines :process_group_id setting with default 0" do
        attr = settings_schema.attributes[:process_group_id]
        expect(attr).to be_present
        expect(attr.type).to eq(:integer)
        expect(attr.default).to eq(0)
      end

      it "defines :process_status setting as enum" do
        attr = settings_schema.attributes[:process_status]
        expect(attr).to be_present
        expect(attr.type).to eq(:enum)
        expect(attr.build_choices).to match_array(%w(active all upcoming past))
      end

      it "defines :selection_criteria setting as enum" do
        attr = settings_schema.attributes[:selection_criteria]
        expect(attr).to be_present
        expect(attr.type).to eq(:enum)
        expect(attr.build_choices).to match_array(%w(automatic manual))
      end

      it "defines :selected_ids setting as array with default []" do
        attr = settings_schema.attributes[:selected_ids]
        expect(attr).to be_present
        expect(attr.type).to eq(:array)
        expect(attr.default).to eq([])
      end
    end
  end
end
