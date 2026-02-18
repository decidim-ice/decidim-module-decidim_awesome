# frozen_string_literal: true

require "spec_helper"

module Decidim
  module DecidimAwesome
    describe AwesomeProcessesQuery do
      subject { described_class.new(organization, current_user, settings) }

      let(:organization) { create(:organization) }
      let(:current_user) { nil }
      let(:settings) { OpenStruct.new(settings_hash) }
      let(:settings_hash) do
        {
          selection_criteria: "active",
          process_type: "all",
          process_group_id: 0,
          max_results: 6,
          selected_ids: []
        }
      end

      let!(:active_process) { create(:participatory_process, :active, :published, organization:) }
      let!(:past_process) { create(:participatory_process, :past, :published, organization:) }
      let!(:unpublished_process) { create(:participatory_process, :active, :unpublished, organization:) }
      let!(:process_group) { create(:participatory_process_group, organization:) }

      describe "#results with automatic selection" do
        context "with default settings (process_type: 'all')" do
          it "returns active processes and groups" do
            results = subject.results
            expect(results).to include(active_process)
            expect(results).to include(process_group)
          end

          it "does not return past processes" do
            expect(subject.results).not_to include(past_process)
          end

          it "does not return unpublished processes" do
            expect(subject.results).not_to include(unpublished_process)
          end

          it "does not return processes from other organizations" do
            other_org = create(:organization)
            other_process = create(:participatory_process, :active, :published, organization: other_org)
            expect(subject.results).not_to include(other_process)
          end
        end

        context "when process_type is 'processes'" do
          let(:settings_hash) { super().merge(process_type: "processes") }

          it "returns only processes" do
            results = subject.results
            expect(results).to include(active_process)
            expect(results).not_to include(process_group)
          end
        end

        context "when process_type is 'groups'" do
          let(:settings_hash) { super().merge(process_type: "groups") }

          it "returns only groups" do
            results = subject.results
            expect(results).to include(process_group)
            expect(results).not_to include(active_process)
          end
        end

        context "when process_group_id is set to a specific group" do
          let!(:grouped_process) { create(:participatory_process, :active, :published, organization:, participatory_process_group: process_group) }
          let(:settings_hash) { super().merge(process_group_id: process_group.id) }

          it "filters processes by that group" do
            results = subject.results
            expect(results).to include(grouped_process)
            expect(results).not_to include(active_process)
          end
        end

        context "when process_group_id is 0" do
          let(:settings_hash) { super().merge(process_group_id: 0) }

          it "does not filter by group" do
            expect(subject.results).to include(active_process)
          end
        end

        context "when max_results is 2" do
          let(:settings_hash) { super().merge(max_results: 2) }

          let!(:extra_process1) { create(:participatory_process, :active, :published, organization:) }
          let!(:extra_process2) { create(:participatory_process, :active, :published, organization:) }

          it "limits total items returned" do
            expect(subject.results.size).to be <= 2
          end
        end

        context "when max_results is negative" do
          let(:settings_hash) { super().merge(max_results: -1) }

          it "does not raise an error and returns an empty array" do
            expect { subject.results }.not_to raise_error
            expect(subject.results).to eq([])
          end
        end

        context "when processes have different weights" do
          let!(:heavy_process) { create(:participatory_process, :active, :published, organization:, weight: 10) }
          let!(:light_process) { create(:participatory_process, :active, :published, organization:, weight: 1) }
          let(:settings_hash) { super().merge(process_type: "processes") }

          it "sorts processes by weight ascending" do
            results = subject.results
            light_idx = results.index(light_process)
            heavy_idx = results.index(heavy_process)
            expect(light_idx).to be < heavy_idx
          end
        end

        context "when processes have the same weight" do
          let!(:process_a) { create(:participatory_process, :active, :published, organization:, weight: 5) }
          let!(:process_b) { create(:participatory_process, :active, :published, organization:, weight: 5) }
          let(:settings_hash) { super().merge(process_type: "processes") }

          it "uses id as tie-breaker" do
            results = subject.results
            idx_a = results.index(process_a)
            idx_b = results.index(process_b)
            if process_a.id < process_b.id
              expect(idx_a).to be < idx_b
            else
              expect(idx_b).to be < idx_a
            end
          end
        end

        context "when process_type is 'all' (mixed interleaving)" do
          let!(:process2) { create(:participatory_process, :active, :published, organization:, weight: 2) }
          let!(:group2) { create(:participatory_process_group, organization:) }
          let(:settings_hash) { super().merge(process_type: "all", max_results: 10) }

          it "interleaves processes and groups" do
            results = subject.results
            process_indices = results.each_index.select { |i| results[i].is_a?(Decidim::ParticipatoryProcess) }
            group_indices = results.each_index.select { |i| results[i].is_a?(Decidim::ParticipatoryProcessGroup) }

            expect(process_indices).not_to be_empty
            expect(group_indices).not_to be_empty
            expect(results[0]).to be_a(Decidim::ParticipatoryProcess)
            expect(results[1]).to be_a(Decidim::ParticipatoryProcessGroup)
          end
        end

        context "when mixed with more processes than groups" do
          let!(:process2) { create(:participatory_process, :active, :published, organization:, weight: 2) }
          let!(:process3) { create(:participatory_process, :active, :published, organization:, weight: 3) }
          let(:settings_hash) { super().merge(process_type: "all", max_results: 10) }

          it "fills remaining slots with processes after groups run out" do
            results = subject.results
            processes = results.select { |r| r.is_a?(Decidim::ParticipatoryProcess) }
            groups = results.select { |r| r.is_a?(Decidim::ParticipatoryProcessGroup) }
            expect(processes.size).to eq(3)
            expect(groups.size).to eq(1)
            expect(results.size).to eq(4)
          end
        end

        context "when mixed with more groups than processes" do
          let!(:group2) { create(:participatory_process_group, organization:) }
          let!(:group3) { create(:participatory_process_group, organization:) }
          let(:settings_hash) { super().merge(process_type: "all", max_results: 10) }

          it "fills remaining slots with groups after processes run out" do
            results = subject.results
            processes = results.select { |r| r.is_a?(Decidim::ParticipatoryProcess) }
            groups = results.select { |r| r.is_a?(Decidim::ParticipatoryProcessGroup) }
            expect(processes.size).to eq(1)
            expect(groups.size).to eq(3)
          end
        end

        context "when mixed with max_results limiting output" do
          let!(:process2) { create(:participatory_process, :active, :published, organization:, weight: 2) }
          let!(:group2) { create(:participatory_process_group, organization:) }
          let(:settings_hash) { super().merge(process_type: "all", max_results: 3) }

          it "respects max_results" do
            expect(subject.results.size).to eq(3)
          end
        end
      end

      describe "#results with manual selection" do
        let(:settings_hash) do
          {
            selection_criteria: "manual",
            process_type: "all",
            process_group_id: 0,
            max_results: 6,
            selected_ids: selected_ids
          }
        end
        let(:selected_ids) { [] }

        context "with process IDs" do
          let(:selected_ids) { ["process_#{active_process.id}"] }

          it "returns those specific processes" do
            results = subject.results
            expect(results).to include(active_process)
            expect(results).not_to include(past_process)
          end
        end

        context "with group IDs" do
          let(:selected_ids) { ["group_#{process_group.id}"] }

          it "returns those specific groups" do
            results = subject.results
            expect(results).to include(process_group)
            expect(results).not_to include(active_process)
          end
        end

        context "with mix of process and group IDs" do
          let(:selected_ids) { ["process_#{active_process.id}", "group_#{process_group.id}"] }

          it "returns both types" do
            results = subject.results
            expect(results).to include(active_process)
            expect(results).to include(process_group)
          end
        end

        context "when order matters" do
          let(:selected_ids) { ["group_#{process_group.id}", "process_#{active_process.id}", "process_#{past_process.id}"] }

          it "preserves the order from selected_ids" do
            results = subject.results
            expect(results).to eq([process_group, active_process, past_process])
          end
        end

        context "with blank entries" do
          let(:selected_ids) { ["process_#{active_process.id}", "", " "] }

          it "ignores blank strings" do
            expect { subject.results }.not_to raise_error
            expect(subject.results).to include(active_process)
          end
        end

        context "with non-existent IDs" do
          let(:selected_ids) { ["process_#{active_process.id}", "process_99999"] }

          it "returns only existing items" do
            results = subject.results
            expect(results).to include(active_process)
            expect(results.size).to eq(1)
          end
        end

        context "when max_results limits output" do
          let(:selected_ids) do
            ["process_#{active_process.id}", "process_#{past_process.id}", "group_#{process_group.id}"]
          end
          let(:settings_hash) { super().merge(max_results: 1) }

          it "limits output" do
            expect(subject.results.size).to eq(1)
          end
        end

        context "when a past process is selected" do
          let(:selected_ids) { ["process_#{past_process.id}"] }

          it "returns it (manual ignores active filter)" do
            expect(subject.results).to include(past_process)
          end
        end

        context "when an unpublished process is selected" do
          let(:selected_ids) { ["process_#{unpublished_process.id}"] }

          it "does not return it" do
            expect(subject.results).not_to include(unpublished_process)
          end
        end
      end
    end
  end
end
