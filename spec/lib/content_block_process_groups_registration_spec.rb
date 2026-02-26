# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DecidimAwesome do
    let(:content_block_manifest) do
      Decidim.content_blocks.for(:participatory_process_group_homepage).find { |manifest| manifest.name == :awesome_process_groups }
    end

    it "registers the content block for participatory_process_group_homepage" do
      expect(content_block_manifest).to be_present
    end

    it "has the correct cell" do
      expect(content_block_manifest.cell).to eq("decidim/decidim_awesome/content_blocks/awesome_process_groups")
    end

    it "has the correct settings form cell" do
      expect(content_block_manifest.settings_form_cell).to eq("decidim/decidim_awesome/content_blocks/awesome_process_groups_form")
    end

    it "has the correct public name key" do
      expect(content_block_manifest.public_name_key).to eq("decidim.decidim_awesome.content_blocks.awesome_process_groups.name")
    end

    describe "settings" do
      let(:settings_manifest) { content_block_manifest.settings }

      it "has a title attribute" do
        expect(settings_manifest.attributes[:title]).to be_present
        expect(settings_manifest.attributes[:title].type).to eq(:text)
        expect(settings_manifest.attributes[:title].translated).to be(true)
      end

      it "has a max_count attribute" do
        expect(settings_manifest.attributes[:max_count]).to be_present
        expect(settings_manifest.attributes[:max_count].type).to eq(:integer)
        expect(settings_manifest.attributes[:max_count].default).to eq(6)
      end
    end
  end
end
