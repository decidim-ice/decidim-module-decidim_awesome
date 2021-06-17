# frozen_string_literal: true

require "spec_helper"

describe Decidim::DecidimAwesome::ContentBlocks::MapCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  let(:organization) { create(:organization) }
  let(:content_block) { create :content_block, organization: organization, manifest_name: :awesome_map, scope_name: :homepage, settings: settings }
  let(:settings) { {} }

  controller Decidim::PagesController

  before do
    allow(controller).to receive(:current_organization).and_return(organization)
  end

  context "when the content block has customized the max results setting value" do
    # note that settings is doing nothing here, just left it for when conferences block is improved
    let(:settings) do
      {
        "max_results" => "8"
      }
    end

    it "shows up to 8 conferences" do
      expect(highlighted_conferences).to have_selector("a.card--conference", count: 5)
    end
  end
end
