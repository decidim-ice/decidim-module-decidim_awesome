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
          selection_criteria: "automatic",
          process_type: "all",
          process_group_id: 0,
          max_results: 6,
          selected_ids: []
        }
      end

      let!(:process_group) { create(:participatory_process_group, organization:) }
      let!(:active_process) { create(:participatory_process, :active, :published, organization:) }
      let!(:grouped_process) { create(:participatory_process, :active, :published, organization:, participatory_process_group: process_group) }
      let!(:past_process) { create(:participatory_process, :past, :published, organization:) }
      let!(:unpublished_process) { create(:participatory_process, :active, :unpublished, organization:) }

      describe "#results with automatic selection" do
        context "with default settings (process_type: 'all')" do
          it "returns active processes from all types" do
            results = subject.results
            expect(results).to include(active_process)
            expect(results).to include(grouped_process)
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

          it "returns only processes without a group" do
            results = subject.results
            expect(results).to include(active_process)
            expect(results).not_to include(grouped_process)
          end

          context "when process_group_id is set (stale value from UI)" do
            let(:settings_hash) { super().merge(process_type: "processes", process_group_id: process_group.id) }

            it "ignores the group filter and returns ungrouped processes" do
              results = subject.results
              expect(results).to include(active_process)
              expect(results).not_to include(grouped_process)
            end
          end
        end

        context "when process_type is 'groups'" do
          let(:settings_hash) { super().merge(process_type: "groups") }

          it "returns only processes with a group" do
            results = subject.results
            expect(results).to include(grouped_process)
            expect(results).not_to include(active_process)
          end

          context "when restricted to a specific group" do
            let!(:other_group) { create(:participatory_process_group, organization:) }
            let!(:other_grouped) { create(:participatory_process, :active, :published, organization:, participatory_process_group: other_group) }
            let(:settings_hash) { super().merge(process_type: "groups", process_group_id: process_group.id) }

            it "returns only processes from the specified group" do
              results = subject.results
              expect(results).to include(grouped_process)
              expect(results).not_to include(other_grouped)
              expect(results).not_to include(active_process)
            end
          end
        end

        context "when process_status is 'all'" do
          let(:settings_hash) { super().merge(process_status: "all") }

          it "returns both active and past processes" do
            results = subject.results
            expect(results).to include(active_process)
            expect(results).to include(past_process)
          end

          it "does not return unpublished processes" do
            expect(subject.results).not_to include(unpublished_process)
          end
        end

        context "when process_status is 'upcoming'" do
          let!(:upcoming_process) { create(:participatory_process, :upcoming, :published, organization:) }
          let(:settings_hash) { super().merge(process_status: "upcoming") }

          it "returns only upcoming processes" do
            results = subject.results
            expect(results).to include(upcoming_process)
            expect(results).not_to include(active_process)
            expect(results).not_to include(past_process)
          end
        end

        context "when process_status is 'past'" do
          let(:settings_hash) { super().merge(process_status: "past") }

          it "returns only past processes" do
            results = subject.results
            expect(results).to include(past_process)
            expect(results).not_to include(active_process)
          end
        end

        context "when process_status is 'active' (default)" do
          let(:settings_hash) { super().merge(process_status: "active") }

          it "returns only active processes" do
            results = subject.results
            expect(results).to include(active_process)
            expect(results).not_to include(past_process)
          end
        end

        context "when process_group_id is set (type: all)" do
          let(:settings_hash) { super().merge(process_group_id: process_group.id) }

          it "shows processes from that group AND ungrouped processes" do
            results = subject.results
            expect(results).to include(grouped_process)
            expect(results).to include(active_process)
          end

          it "excludes processes from other groups" do
            other_group = create(:participatory_process_group, organization:)
            other_grouped = create(:participatory_process, :active, :published, organization:, participatory_process_group: other_group)
            results = subject.results
            expect(results).not_to include(other_grouped)
          end
        end

        context "when process_group_id is 0" do
          let(:settings_hash) { super().merge(process_group_id: 0) }

          it "does not filter by group" do
            results = subject.results
            expect(results).to include(active_process)
            expect(results).to include(grouped_process)
          end
        end

        context "when max_results is 1" do
          let(:settings_hash) { super().merge(max_results: 1) }

          it "limits total items returned" do
            expect(subject.results.size).to eq(1)
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

          it "sorts processes by weight ascending" do
            results = subject.results
            light_idx = results.index(light_process)
            heavy_idx = results.index(heavy_process)
            expect(light_idx).to be < heavy_idx
          end
        end

        context "when processes have the same weight" do
          let!(:first_process) { create(:participatory_process, :active, :published, organization:, weight: 1) }
          let!(:second_process) { create(:participatory_process, :active, :published, organization:, weight: 1) }

          it "breaks ties by id ascending" do
            results = subject.results
            first_idx = results.index(first_process)
            second_idx = results.index(second_process)
            expect(first_idx).to be < second_idx
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
          let(:selected_ids) { [active_process.id.to_s] }

          it "returns those specific processes" do
            results = subject.results
            expect(results).to include(active_process)
            expect(results).not_to include(grouped_process)
          end
        end

        context "when order matters" do
          let(:selected_ids) { [grouped_process.id.to_s, active_process.id.to_s] }

          it "preserves the order from selected_ids" do
            expect(subject.results).to eq([grouped_process, active_process])
          end
        end

        context "with blank entries" do
          let(:selected_ids) { [active_process.id.to_s, "", " "] }

          it "ignores blank strings" do
            expect { subject.results }.not_to raise_error
            expect(subject.results).to include(active_process)
          end
        end

        context "with non-existent IDs" do
          let(:selected_ids) { [active_process.id.to_s, "99999"] }

          it "returns only existing items" do
            results = subject.results
            expect(results).to include(active_process)
            expect(results.size).to eq(1)
          end
        end

        context "when max_results limits output" do
          let(:selected_ids) { [active_process.id.to_s, grouped_process.id.to_s, past_process.id.to_s] }
          let(:settings_hash) { super().merge(max_results: 1) }

          it "limits output" do
            expect(subject.results.size).to eq(1)
          end
        end

        context "when a past process is selected" do
          let(:selected_ids) { [past_process.id.to_s] }

          it "returns it (manual ignores status filter)" do
            expect(subject.results).to include(past_process)
          end
        end

        context "when an unpublished process is selected" do
          let(:selected_ids) { [unpublished_process.id.to_s] }

          it "does not return it" do
            expect(subject.results).not_to include(unpublished_process)
          end
        end

        context "when restricted to a specific group (type: all)" do
          let!(:other_process) { create(:participatory_process, :active, :published, organization:) }
          let(:selected_ids) { [grouped_process.id.to_s, other_process.id.to_s] }
          let(:settings_hash) { super().merge(process_group_id: process_group.id) }

          it "includes grouped process and ungrouped process" do
            results = subject.results
            expect(results).to include(grouped_process)
            expect(results).to include(other_process)
          end
        end

        context "when restricted to a specific group (type: groups)" do
          let!(:other_process) { create(:participatory_process, :active, :published, organization:) }
          let(:selected_ids) { [grouped_process.id.to_s, other_process.id.to_s] }
          let(:settings_hash) { super().merge(process_type: "groups", process_group_id: process_group.id) }

          it "returns only processes from that group" do
            results = subject.results
            expect(results).to include(grouped_process)
            expect(results).not_to include(other_process)
          end
        end

        context "when process_type is 'processes'" do
          let(:selected_ids) { [active_process.id.to_s, grouped_process.id.to_s] }
          let(:settings_hash) { super().merge(process_type: "processes") }

          it "returns only processes without a group" do
            results = subject.results
            expect(results).to include(active_process)
            expect(results).not_to include(grouped_process)
          end

          context "when process_group_id is set (stale value from UI)" do
            let(:settings_hash) { super().merge(process_type: "processes", process_group_id: process_group.id) }

            it "ignores the group filter and returns ungrouped processes" do
              results = subject.results
              expect(results).to include(active_process)
              expect(results).not_to include(grouped_process)
            end
          end
        end
      end
    end
  end
end
