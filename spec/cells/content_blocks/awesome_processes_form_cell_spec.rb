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
        expect(labels).to include("All processes")
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

    describe "#process_status_options" do
      it "returns 4 options" do
        options = cell_instance.process_status_options
        expect(options.size).to eq(4)
      end

      it "includes active, all, upcoming, and past values" do
        values = cell_instance.process_status_options.map(&:last)
        expect(values).to eq(%w(active all upcoming past))
      end
    end

    describe "#selection_criteria_options" do
      it "returns 2 options" do
        options = cell_instance.selection_criteria_options
        expect(options.size).to eq(2)
      end

      it "includes automatic and manual values" do
        values = cell_instance.selection_criteria_options.map(&:last)
        expect(values).to eq(%w(automatic manual))
      end
    end

    describe "#processes_for_select" do
      it "returns only processes (no group cards)" do
        options = cell_instance.processes_for_select
        values = options.map { |_, val| val }
        expect(values).to include(published_process.id.to_s)
        expect(values).to all(match(/\A\d+\z/))
      end

      it "includes data-group-id and data-status attributes" do
        options = cell_instance.processes_for_select
        _, _, attrs = options.first
        expect(attrs).to have_key("data-group-id")
        expect(attrs).to have_key("data-status")
      end

      it "sets data-status based on process dates" do
        active = create(:participatory_process, :active, :published, organization:)
        past = create(:participatory_process, :past, :published, organization:)
        upcoming = create(:participatory_process, :upcoming, :published, organization:)
        options = cell_instance.processes_for_select

        _, _, active_attrs = options.find { |_, val| val == active.id.to_s }
        _, _, past_attrs = options.find { |_, val| val == past.id.to_s }
        _, _, upcoming_attrs = options.find { |_, val| val == upcoming.id.to_s }
        expect(active_attrs["data-status"]).to eq("active")
        expect(past_attrs["data-status"]).to eq("past")
        expect(upcoming_attrs["data-status"]).to eq("upcoming")
      end

      it "does not include unpublished processes" do
        values = cell_instance.processes_for_select.map { |_, val| val }
        expect(values).not_to include(unpublished_process.id.to_s)
      end

      it "does not include other organization's processes" do
        other_org = create(:organization)
        other_process = create(:participatory_process, :published, organization: other_org)
        values = cell_instance.processes_for_select.map { |_, val| val }
        expect(values).not_to include(other_process.id.to_s)
      end

      context "when there are saved selections" do
        let!(:second_process) { create(:participatory_process, :published, organization:) }
        let(:settings) { { selected_ids: [second_process.id.to_s, published_process.id.to_s] } }

        it "puts selected items first in saved order" do
          options = cell_instance.processes_for_select
          values = options.map { |_, val| val }
          expect(values.index(second_process.id.to_s)).to eq(0)
          expect(values.index(published_process.id.to_s)).to eq(1)
        end
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
