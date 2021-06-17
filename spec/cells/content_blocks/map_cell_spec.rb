# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe ContentBlocks::MapCell, type: :cell do
    subject { cell(content_block.cell, content_block).call }

    let(:organization) { create(:organization) }
    let(:content_block) { create :content_block, organization: organization, manifest_name: :awesome_map, scope_name: :homepage, settings: settings }
    let(:settings) { {} }

    controller Decidim::PagesController

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "shows the map" do
      expect(subject).to have_selector("#awesome-map")
      expect(subject).to have_content("window.AwesomeMap.categories")
    end

    it "do not show the title" do
      expect(subject).not_to have_selector("h3.section-heading")
    end

    context "when the content block has a title" do
      let(:settings) do
        {
          "title" => {"en" => "Look this beautiful map!"}
        }
      end

      it "shows the title" do
        expect(subject).to have_selector("h3.section-heading")
        expect(subject).to have_content("Look this beautiful map!")
      end
    end
  end
end
