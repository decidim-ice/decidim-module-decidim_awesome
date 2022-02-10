# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe MapHelper, type: :helper do
    let(:snippets) { defined?(Decidim::Snippets) ? Decidim::Snippets.new : nil }
    let(:current_participatory_space) { create(:participatory_process) }
    let(:current_component) do
      create(:component, participatory_space: current_participatory_space, manifest_name: "awesome_map")
    end
    let(:components) do
      [
        create(:component, participatory_space: current_participatory_space, manifest_name: "meetings"),
        create(:component, participatory_space: current_participatory_space, manifest_name: "proposals")
      ]
    end
    let!(:category) { create(:category, participatory_space: current_participatory_space) }
    let!(:subcategory) { create(:category, parent: category) }
    let(:categories) do
      [{
        id: category.id,
        name: category.name["en"],
        parent: nil,
        color: "#ffaa33"
      }, {
        id: subcategory.id,
        name: subcategory.name["en"],
        parent: category.id,
        color: "#ffaa33"
      }]
    end

    before do
      allow(helper).to receive(:current_participatory_space).and_return(current_participatory_space)
      allow(helper).to receive(:current_organization).and_return(current_participatory_space.organization)
      allow(helper).to receive(:current_component).and_return(current_component)
      allow(helper).to receive(:snippets).and_return(snippets)
      allow(helper).to receive(:translated_attribute) do |string|
        string["en"]
      end
    end

    describe "awesome_map_for" do
      it "returns a map tag" do
        body = -> { "<div>html body</div>".html_safe }
        expect(helper.awesome_map_for(components, &body)).to include("<div>html body</div>")
        expect(helper.awesome_map_for(components, &body)).to include("data-components=")
        expect(helper.awesome_map_for(components, &body)).to include('data-collapsed="false"')
      end
    end

    describe "current_categories" do
      before do
        allow(helper).to receive(:hsv_to_rgb).and_return([255, 0xAA, 0x33])
      end

      it "return formatted categories" do
        expect(helper.current_categories(current_participatory_space.categories)).to eq(categories)
      end
    end

    describe "hsv_to_rgb" do
      it "converst hsv to rgb" do
        expect(helper.send(:hsv_to_rgb, 0.3, 0.5, 0.7)).to eq([107, 179, 89])
        expect(helper.send(:hsv_to_rgb, 0, 1, 1)).to eq([256, 0, 0])
        expect(helper.send(:hsv_to_rgb, 5 / 6r, 0, 1)).to eq([256, 256, 256])
        expect(helper.send(:hsv_to_rgb, 4 / 6r, 1, 0)).to eq([0, 0, 0])
        expect(helper.send(:hsv_to_rgb, 3 / 6r, 0.4, 0.2)).to eq([30, 51, 51])
        expect(helper.send(:hsv_to_rgb, 2 / 6r, 0.5, 0.4)).to eq([51, 102, 51])
        expect(helper.send(:hsv_to_rgb, 1 / 6r, 0.5, 0.1)).to eq([25, 25, 12])
      end
    end
  end
end
