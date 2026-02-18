# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe ContentBlocks::AwesomeProcessesFormCell, type: :cell do
    let(:organization) { create(:organization) }
    let(:content_block) { create(:content_block, organization:, manifest_name: :awesome_processes, scope_name: :homepage, settings:) }
    let(:settings) { {} }
    let!(:published_process) { create(:participatory_process, :published, organization:) }
    let!(:unpublished_process) { create(:participatory_process, :unpublished, organization:) }
    let!(:process_group) { create(:participatory_process_group, organization:) }

    let(:form) do
      Decidim::FormBuilder.new(
        "content_block",
        content_block,
        ActionView::Base.new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, ActionController::Base.new),
        {}
      )
    end

    let(:cell_instance) do
      cell(
        "decidim/decidim_awesome/content_blocks/awesome_processes_form",
        form,
        content_block: content_block
      )
    end

    controller Decidim::PagesController

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    describe "#process_type_options" do
      it "returns 3 options" do
        options = cell_instance.process_type_options
        expect(options.size).to eq(3)
      end

      it "includes all, processes, and groups values" do
        values = cell_instance.process_type_options.map(&:last)
        expect(values).to eq(%w(all processes groups))
      end

      it "has translated labels" do
        labels = cell_instance.process_type_options.map(&:first)
        expect(labels).to include("All processes and groups mixed")
        expect(labels).to include("Only processes")
        expect(labels).to include("Only process groups")
      end
    end

    describe "#process_group_options" do
      it "includes 'Any group' as the first option" do
        options = cell_instance.process_group_options
        expect(options.first).to eq(["Any group", 0])
      end

      it "includes all organization groups" do
        options = cell_instance.process_group_options
        group_ids = options.map(&:last)
        expect(group_ids).to include(process_group.id)
      end

      it "does not include other organization's groups" do
        other_org = create(:organization)
        other_group = create(:participatory_process_group, organization: other_org)
        options = cell_instance.process_group_options
        group_ids = options.map(&:last)
        expect(group_ids).not_to include(other_group.id)
      end
    end

    describe "#selection_criteria_options" do
      it "returns 2 options" do
        options = cell_instance.selection_criteria_options
        expect(options.size).to eq(2)
      end

      it "includes active and manual values" do
        values = cell_instance.selection_criteria_options.map(&:last)
        expect(values).to eq(%w(active manual))
      end

      it "has translated labels" do
        labels = cell_instance.selection_criteria_options.map(&:first)
        expect(labels).to include("Active")
        expect(labels).to include("Manual")
      end
    end

    describe "#processes_for_select" do
      it "returns published processes with correct format" do
        options = cell_instance.processes_for_select
        process_options = options.select { |_, v| v.start_with?("process_") }
        expect(process_options).not_to be_empty
        label, value = process_options.first
        expect(label).to start_with("##{published_process.id} - ")
        expect(value).to eq("process_#{published_process.id}")
      end

      it "returns groups with [Group] prefix" do
        options = cell_instance.processes_for_select
        group_options = options.select { |_, v| v.start_with?("group_") }
        expect(group_options).not_to be_empty
        label, value = group_options.first
        expect(label).to start_with("[Group]")
        expect(value).to eq("group_#{process_group.id}")
      end

      it "does not include unpublished processes" do
        options = cell_instance.processes_for_select
        values = options.map(&:last)
        expect(values).not_to include("process_#{unpublished_process.id}")
      end

      it "does not include other organization's data" do
        other_org = create(:organization)
        other_process = create(:participatory_process, :published, organization: other_org)
        other_group = create(:participatory_process_group, organization: other_org)
        options = cell_instance.processes_for_select
        values = options.map(&:last)
        expect(values).not_to include("process_#{other_process.id}")
        expect(values).not_to include("group_#{other_group.id}")
      end
    end

    describe "#i18n_scope" do
      it "returns correct scope" do
        expect(cell_instance.i18n_scope).to eq("decidim.decidim_awesome.content_blocks.awesome_processes")
      end
    end

    describe "#content_block" do
      it "returns the content_block from options" do
        expect(cell_instance.content_block).to eq(content_block)
      end
    end
  end
end
