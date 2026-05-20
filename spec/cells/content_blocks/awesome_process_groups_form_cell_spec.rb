# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe ContentBlocks::AwesomeProcessGroupsFormCell, type: :cell do
    let(:organization) { create(:organization) }
    let(:process_group) { create(:participatory_process_group, organization:) }
    let(:form) do
      Decidim::FormBuilder.new(
        "content_block",
        Decidim::Admin::ContentBlockForm.from_model(content_block),
        ActionView::Base.empty,
        {}
      )
    end
    let(:content_block) { create(:content_block, organization:, manifest_name: :awesome_process_groups, scope_name: :participatory_process_group_homepage, scoped_resource_id: process_group.id) }

    controller Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessGroupLandingPageContentBlocksController

    subject { cell(content_block.settings_form_cell, form, content_block:).call }

    it "renders the title field" do
      expect(subject).to have_content("Block title")
    end

    it "renders the max_count field" do
      expect(subject).to have_content("Maximum amount of elements to show")
    end

    it "exposes the content_block" do
      cell_instance = cell(content_block.settings_form_cell, form, content_block:)
      expect(cell_instance.content_block).to eq(content_block)
    end
  end
end
