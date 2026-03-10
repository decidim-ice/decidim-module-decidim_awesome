# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe BaseCellOverride do
    let(:organization) { create(:organization) }

    controller Decidim::PagesController

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    describe "#block_id" do
      context "when cell defines its own block_id" do
        let(:content_block) { create(:content_block, organization:, manifest_name: :awesome_landing_menu, scope_name: :homepage) }

        it "keeps the original block_id" do
          cell_instance = cell(content_block.cell, content_block)
          expect(cell_instance.block_id).to eq("awesome-landing-menu-#{content_block.id}")
        end
      end

      context "with two blocks of the same manifest" do
        let(:block_a) { create(:content_block, organization:, manifest_name: :awesome_landing_menu, scope_name: :homepage) }
        let(:block_b) { create(:content_block, organization:, manifest_name: :awesome_landing_menu, scope_name: :homepage) }

        it "returns unique IDs" do
          cell_a = cell(block_a.cell, block_a)
          cell_b = cell(block_b.cell, block_b)
          expect(cell_a.block_id).not_to eq(cell_b.block_id)
        end
      end
    end
  end
end
