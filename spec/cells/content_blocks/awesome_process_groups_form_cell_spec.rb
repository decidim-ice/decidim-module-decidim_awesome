# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe ContentBlocks::AwesomeProcessGroupsFormCell, type: :cell do
    let(:organization) { create(:organization) }
    let(:form) do
      Decidim::FormBuilder.new(
        "content_block",
        Decidim::Admin::ContentBlockForm.from_model(content_block),
        ActionView::Base.empty,
        {}
      )
    end
    let(:content_block) { create(:content_block, organization:, manifest_name: :awesome_process_groups, scope_name: :homepage) }

    controller Decidim::Admin::OrganizationHomepageContentBlocksController

    subject { cell(content_block.settings_form_cell, form, content_block:).call }

    it "renders the title field" do
      expect(subject).to have_content("Block title")
    end
  end
end
