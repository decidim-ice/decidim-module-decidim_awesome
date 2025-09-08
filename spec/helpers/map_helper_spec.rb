# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe MapHelper do
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
    let(:organization) { current_participatory_space.organization }
    let(:root_taxonomy) { create(:taxonomy, organization:) }
    let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
    let(:taxonomies) do
      [{
        id: root_taxonomy.id,
        name: root_taxonomy.name["en"],
        parent: nil,
        color: "#ffaa33"
      }, {
        id: taxonomy.id,
        name: taxonomy.name["en"],
        parent: root_taxonomy.id,
        color: "#ffaa33"
      }]
    end

    before do
      allow(helper).to receive_messages(current_participatory_space:, current_organization: organization, current_component:, snippets:)
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

    describe "current_taxonomies" do
      before do
        allow(helper).to receive(:hsv_to_rgb).and_return([255, 0xAA, 0x33])
      end

      it "return formatted taxonomies" do
        # Only root_taxonomies can be passed to the current_taxonomies method
        expect(helper.current_taxonomies(organization.taxonomies.filter { |t| t.parent_id.nil? })).to eq(taxonomies)
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
