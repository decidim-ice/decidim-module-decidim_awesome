# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe ContentBlocks::AwesomeProcessGroupsCell, type: :cell do
    subject { block_cell.call }

    let(:organization) { create(:organization) }
    let(:process_group) { create(:participatory_process_group, organization:) }
    let(:content_block) { create(:content_block, organization:, manifest_name: :awesome_process_groups, scope_name: :participatory_process_group_homepage, scoped_resource_id: process_group.id, settings:) }
    let(:settings) { {} }
    let(:block_cell) { cell(content_block.cell, content_block) }

    controller Decidim::ParticipatoryProcesses::ParticipatoryProcessGroupsController

    before do
      allow(controller).to receive(:group).and_return(process_group)
    end

    context "when there are no processes belonging to the group" do
      it "does not render content" do
        expect(subject).to have_no_content("Participatory processes")
      end
    end

    context "when there are processes belonging to the group" do
      let!(:grouped_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Climate Action Plan" }) }

      it "renders the default title" do
        expect(subject).to have_content("Participatory processes")
      end

      it "renders the process card" do
        expect(subject).to have_content("Climate Action Plan")
      end

      it "renders the status filter tabs" do
        expect(subject).to have_content("Active")
        expect(subject).to have_content("Past")
        expect(subject).to have_content("Upcoming")
        expect(subject).to have_content("All")
      end

      it "renders the status label" do
        expect(subject).to have_content("Status:")
      end

      it "renders status tabs as links" do
        expect(subject).to have_link("All (1)")
      end
    end

    context "when processes belong to another group" do
      let(:other_group) { create(:participatory_process_group, organization:) }
      let!(:grouped_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Our Process" }) }
      let!(:other_process) { create(:participatory_process, :published, organization:, participatory_process_group: other_group, title: { en: "Other Group Process" }) }

      it "only shows processes from the current group" do
        expect(subject).to have_content("Our Process")
        expect(subject).to have_no_content("Other Group Process")
      end
    end

    context "when processes do not belong to any group" do
      let!(:ungrouped_process) { create(:participatory_process, :published, organization:, title: { en: "Standalone Process" }) }

      it "does not show ungrouped processes" do
        expect(subject).to have_no_content("Standalone Process")
      end
    end

    context "when a custom title is set" do
      let!(:grouped_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group) }
      let(:settings) { { "title" => { "en" => "Active processes" } } }

      it "renders the custom title" do
        expect(subject).to have_content("Active processes")
      end

      it "does not render the default title" do
        expect(subject).to have_no_content("Participatory processes")
      end
    end

    context "with active and past processes" do
      let!(:active_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Current Project" }, start_date: 1.month.ago, end_date: 1.month.from_now) }
      let!(:past_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Finished Project" }, start_date: 3.months.ago, end_date: 1.month.ago) }

      it "renders both processes" do
        expect(subject).to have_content("Current Project")
        expect(subject).to have_content("Finished Project")
      end

      it "shows counts in filter tabs" do
        block_cell.call
        expect(block_cell.count_for("active")).to eq(1)
        expect(block_cell.count_for("past")).to eq(1)
        expect(block_cell.count_for("upcoming")).to eq(0)
        expect(block_cell.count_for("all")).to eq(2)
      end
    end

    context "with an upcoming process" do
      let!(:upcoming_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Future Project" }, start_date: 1.month.from_now, end_date: 2.months.from_now) }

      it "renders the upcoming process card" do
        expect(subject).to have_content("Future Project")
      end

      it "counts upcoming correctly" do
        block_cell.call
        expect(block_cell.count_for("upcoming")).to eq(1)
        expect(block_cell.count_for("active")).to eq(0)
      end
    end

    context "when process is not published" do
      let!(:unpublished_process) { create(:participatory_process, :unpublished, organization:, participatory_process_group: process_group, title: { en: "Draft Process" }) }

      it "does not show unpublished processes" do
        expect(subject).to have_no_content("Draft Process")
      end
    end

    describe "cell methods" do
      let!(:grouped_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group) }

      describe "#max_count" do
        it "returns default max_count of 6" do
          expect(block_cell.max_count).to eq(6)
        end

        context "when max_count is set to 3" do
          let(:settings) { { "max_count" => 3 } }

          it "returns the configured value" do
            expect(block_cell.max_count).to eq(3)
          end
        end

        context "when max_count is 0" do
          let(:settings) { { "max_count" => 0 } }

          it "returns at least 1" do
            expect(block_cell.max_count).to eq(1)
          end
        end
      end

      describe "#current_status" do
        it "defaults to 'all'" do
          expect(block_cell.current_status).to eq("all")
        end

        it "reads status from params" do
          allow(controller).to receive(:params).and_return(ActionController::Parameters.new(status: "active"))
          expect(block_cell.current_status).to eq("active")
        end

        it "rejects invalid status" do
          allow(controller).to receive(:params).and_return(ActionController::Parameters.new(status: "invalid"))
          expect(block_cell.current_status).to eq("all")
        end
      end

      describe "#selected_taxonomy_ids" do
        it "defaults to empty array" do
          expect(block_cell.selected_taxonomy_ids).to eq([])
        end

        it "reads taxonomy_ids from params" do
          allow(controller).to receive(:params).and_return(ActionController::Parameters.new(taxonomy_ids: %w(1 2 3)))
          expect(block_cell.selected_taxonomy_ids).to eq([1, 2, 3])
        end

        it "rejects zero values" do
          allow(controller).to receive(:params).and_return(ActionController::Parameters.new(taxonomy_ids: %w(0 5)))
          expect(block_cell.selected_taxonomy_ids).to eq([5])
        end

        it "deduplicates repeated IDs" do
          allow(controller).to receive(:params).and_return(ActionController::Parameters.new(taxonomy_ids: %w(3 3 7)))
          expect(block_cell.selected_taxonomy_ids).to eq([3, 7])
        end
      end

      describe "#current_page" do
        it "defaults to 1" do
          expect(block_cell.current_page).to eq(1)
        end

        it "reads page from params" do
          allow(controller).to receive(:params).and_return(ActionController::Parameters.new(page: "3"))
          expect(block_cell.current_page).to eq(3)
        end
      end

      describe "#filter_url" do
        it "omits status param when status is 'all'" do
          expect(block_cell.filter_url).not_to include("status=")
        end

        it "includes status param when not 'all'" do
          allow(controller).to receive(:params).and_return(ActionController::Parameters.new(status: "active"))
          expect(block_cell.filter_url).to include("status=active")
        end

        it "overrides current status with provided value" do
          expect(block_cell.filter_url(status: "past")).to include("status=past")
        end

        it "omits status param when overriding to 'all'" do
          allow(controller).to receive(:params).and_return(ActionController::Parameters.new(status: "active"))
          expect(block_cell.filter_url(status: "all")).not_to include("status=")
        end

        it "includes taxonomy_ids when present in params" do
          allow(controller).to receive(:params).and_return(ActionController::Parameters.new(taxonomy_ids: %w(1 2)))
          expect(block_cell.filter_url).to include("taxonomy_ids")
        end
      end

      describe "#pagination_params" do
        it "returns empty hash when defaults" do
          expect(block_cell.send(:pagination_params)).to eq({})
        end

        it "includes status when not 'all'" do
          allow(controller).to receive(:params).and_return(ActionController::Parameters.new(status: "active"))
          expect(block_cell.send(:pagination_params)).to eq({ status: "active" })
        end

        it "includes taxonomy_ids when present" do
          allow(controller).to receive(:params).and_return(ActionController::Parameters.new(taxonomy_ids: %w(5 10)))
          expect(block_cell.send(:pagination_params)).to eq({ taxonomy_ids: [5, 10] })
        end

        it "includes both status and taxonomy_ids" do
          allow(controller).to receive(:params).and_return(ActionController::Parameters.new(status: "past", taxonomy_ids: %w(3)))
          expect(block_cell.send(:pagination_params)).to eq({ status: "past", taxonomy_ids: [3] })
        end
      end
    end

    describe "results count" do
      let!(:process1) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Process One" }) }
      let!(:process2) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Process Two" }) }

      it "displays the total count of filtered processes" do
        expect(subject).to have_content("2 processes found")
      end

      context "with a single process" do
        let!(:process2) { nil }

        it "uses singular form" do
          expect(subject).to have_content("1 process found")
        end
      end
    end

    describe "taxonomy filters" do
      context "when taxonomy filters are available" do
        let!(:grouped_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Filtered Process" }) }
        let(:root_taxonomy) { create(:taxonomy, organization:, name: { en: "Topics" }) }
        let(:child_taxonomy) { create(:taxonomy, organization:, parent: root_taxonomy, name: { en: "Environment" }) }
        let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
        let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_taxonomy) }
        let!(:taxonomization) { create(:taxonomization, taxonomy: child_taxonomy, taxonomizable: grouped_process) }

        it "renders the filter by label" do
          expect(subject).to have_content("Filter by:")
        end

        it "renders the taxonomy group name" do
          expect(subject).to have_content("Topics")
        end

        it "renders the taxonomy item name" do
          expect(subject).to have_content("Environment")
        end

        it "reports taxonomy filters as available" do
          block_cell.call
          expect(block_cell.taxonomy_filters_available?).to be(true)
        end

        it "builds correct taxonomy filter groups structure" do
          block_cell.call
          groups = block_cell.taxonomy_filter_groups
          expect(groups.length).to eq(1)
          expect(groups.first[:name]).to eq("Topics")
          expect(groups.first[:root_id]).to eq(root_taxonomy.id)
          expect(groups.first[:items].first[:name]).to eq("Environment")
          expect(groups.first[:items].first[:id]).to eq(child_taxonomy.id)
        end

        describe "#selected_taxonomy_tags" do
          it "returns empty array when no taxonomy_ids in params" do
            block_cell.call
            expect(block_cell.selected_taxonomy_tags).to eq([])
          end

          it "returns matching tags when taxonomy_ids match filter items" do
            allow(controller).to receive(:params).and_return(ActionController::Parameters.new(taxonomy_ids: [child_taxonomy.id.to_s]))
            block_cell.call
            tags = block_cell.selected_taxonomy_tags
            expect(tags.length).to eq(1)
            expect(tags.first[:name]).to eq("Environment")
            expect(tags.first[:id]).to eq(child_taxonomy.id)
          end

          it "ignores taxonomy_ids not present in any filter group" do
            allow(controller).to receive(:params).and_return(ActionController::Parameters.new(taxonomy_ids: ["999999"]))
            block_cell.call
            expect(block_cell.selected_taxonomy_tags).to eq([])
          end
        end
      end

      context "when taxonomy filters have multiple groups" do
        let!(:grouped_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group) }
        let(:root_taxonomy_a) { create(:taxonomy, organization:, name: { en: "Scope" }) }
        let(:root_taxonomy_b) { create(:taxonomy, organization:, name: { en: "Category" }) }
        let(:child_a) { create(:taxonomy, organization:, parent: root_taxonomy_a, name: { en: "Urban" }) }
        let(:child_b) { create(:taxonomy, organization:, parent: root_taxonomy_b, name: { en: "Health" }) }
        let(:filter_a) { create(:taxonomy_filter, root_taxonomy: root_taxonomy_a) }
        let(:filter_b) { create(:taxonomy_filter, root_taxonomy: root_taxonomy_b) }
        let!(:filter_item_a) { create(:taxonomy_filter_item, taxonomy_filter: filter_a, taxonomy_item: child_a) }
        let!(:filter_item_b) { create(:taxonomy_filter_item, taxonomy_filter: filter_b, taxonomy_item: child_b) }
        let!(:taxonomization_a) { create(:taxonomization, taxonomy: child_a, taxonomizable: grouped_process) }
        let!(:taxonomization_b) { create(:taxonomization, taxonomy: child_b, taxonomizable: grouped_process) }

        it "renders both taxonomy group names" do
          expect(subject).to have_content("Scope")
          expect(subject).to have_content("Category")
        end

        it "renders taxonomy items from both groups" do
          expect(subject).to have_content("Urban")
          expect(subject).to have_content("Health")
        end
      end

      context "when no taxonomy filters exist" do
        let!(:grouped_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group) }

        it "does not render the filter by label" do
          expect(subject).to have_no_content("Filter by:")
        end

        it "reports taxonomy filters as not available" do
          block_cell.call
          expect(block_cell.taxonomy_filters_available?).to be(false)
        end
      end

      context "when taxonomy items have hierarchy (parent-child)" do
        let!(:grouped_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group) }
        let!(:second_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group) }
        let(:root_taxonomy) { create(:taxonomy, organization:, name: { en: "Topics" }) }
        let(:parent_taxonomy) { create(:taxonomy, organization:, parent: root_taxonomy, name: { en: "Environment" }) }
        let(:child_water) { create(:taxonomy, organization:, parent: parent_taxonomy, name: { en: "Water" }) }
        let(:child_air) { create(:taxonomy, organization:, parent: parent_taxonomy, name: { en: "Air" }) }
        let(:sibling_taxonomy) { create(:taxonomy, organization:, parent: root_taxonomy, name: { en: "Transport" }) }
        let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
        let!(:fi_parent) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: parent_taxonomy) }
        let!(:fi_water) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_water) }
        let!(:fi_air) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_air) }
        let!(:fi_transport) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: sibling_taxonomy) }
        let!(:taxonomization_water) { create(:taxonomization, taxonomy: child_water, taxonomizable: grouped_process) }
        let!(:taxonomization_air) { create(:taxonomization, taxonomy: child_air, taxonomizable: grouped_process) }
        let!(:taxonomization_transport) { create(:taxonomization, taxonomy: sibling_taxonomy, taxonomizable: second_process) }

        it "assigns depth 0 to direct children of root and depth 1 to grandchildren" do
          block_cell.call
          groups = block_cell.taxonomy_filter_groups
          items = groups.first[:items]
          env_item = items.find { |it| it[:id] == parent_taxonomy.id }
          water_item = items.find { |it| it[:id] == child_water.id }
          air_item = items.find { |it| it[:id] == child_air.id }
          transport_item = items.find { |it| it[:id] == sibling_taxonomy.id }

          expect(env_item[:depth]).to eq(0)
          expect(water_item[:depth]).to eq(1)
          expect(air_item[:depth]).to eq(1)
          expect(transport_item[:depth]).to eq(0)
        end

        it "sorts children immediately after their parent" do
          block_cell.call
          groups = block_cell.taxonomy_filter_groups
          items = groups.first[:items]
          names = items.map { |it| it[:name] }
          env_idx = names.index("Environment")
          water_idx = names.index("Water")
          air_idx = names.index("Air")
          transport_idx = names.index("Transport")

          expect(water_idx).to be > env_idx
          expect(air_idx).to be > env_idx
          expect(transport_idx).to be > water_idx
        end

        it "renders child items with is-child CSS class" do
          expect(subject).to have_css(".process-groups-filter-dropdown__item.is-child", count: 2)
        end

        it "renders parent items without is-child CSS class" do
          parent_items = subject.native.css(".process-groups-filter-dropdown__item").reject { |el| el["class"].include?("is-child") }
          expect(parent_items.size).to eq(2)
        end
      end

      context "when taxonomy filter exists but has no items" do
        let!(:grouped_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group) }
        let(:root_taxonomy) { create(:taxonomy, organization:, name: { en: "Empty Root" }) }
        let!(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }

        it "does not render the filter by label" do
          expect(subject).to have_no_content("Filter by:")
        end

        it "reports taxonomy filters as not available" do
          block_cell.call
          expect(block_cell.taxonomy_filters_available?).to be(false)
        end
      end

      context "when duplicate taxonomy filters exist for the same root" do
        let!(:grouped_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group) }
        let(:root_taxonomy) { create(:taxonomy, organization:, name: { en: "Scope" }) }
        let(:child_a) { create(:taxonomy, organization:, parent: root_taxonomy, name: { en: "Scope 1" }) }
        let(:child_b) { create(:taxonomy, organization:, parent: root_taxonomy, name: { en: "Scope 2" }) }
        let(:filter_one) { create(:taxonomy_filter, root_taxonomy:) }
        let(:filter_two) { create(:taxonomy_filter, root_taxonomy:) }
        let!(:item_a) { create(:taxonomy_filter_item, taxonomy_filter: filter_one, taxonomy_item: child_a) }
        let!(:item_b) { create(:taxonomy_filter_item, taxonomy_filter: filter_two, taxonomy_item: child_b) }
        let!(:item_dup) { create(:taxonomy_filter_item, taxonomy_filter: filter_two, taxonomy_item: child_a) }
        let!(:taxonomization_a) { create(:taxonomization, taxonomy: child_a, taxonomizable: grouped_process) }
        let!(:taxonomization_b) { create(:taxonomization, taxonomy: child_b, taxonomizable: grouped_process) }

        it "merges items into a single group and deduplicates" do
          block_cell.call
          groups = block_cell.taxonomy_filter_groups
          expect(groups.length).to eq(1)
          expect(groups.first[:name]).to eq("Scope")
          item_ids = groups.first[:items].map { |item| item[:id] }
          expect(item_ids).to contain_exactly(child_a.id, child_b.id)
        end
      end

      context "when taxonomy item has no processes in the group" do
        let!(:grouped_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group) }
        let(:root_taxonomy) { create(:taxonomy, organization:, name: { en: "Topics" }) }
        let(:child_used) { create(:taxonomy, organization:, parent: root_taxonomy, name: { en: "Environment" }) }
        let(:child_unused) { create(:taxonomy, organization:, parent: root_taxonomy, name: { en: "Unused Topic" }) }
        let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
        let!(:fi_used) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_used) }
        let!(:fi_unused) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_unused) }
        let!(:taxonomization) { create(:taxonomization, taxonomy: child_used, taxonomizable: grouped_process) }

        it "shows only taxonomy items used by processes" do
          block_cell.call
          groups = block_cell.taxonomy_filter_groups
          item_names = groups.first[:items].map { |it| it[:name] }
          expect(item_names).to include("Environment")
          expect(item_names).not_to include("Unused Topic")
        end
      end

      context "when no process in the group uses any taxonomy from a root" do
        let!(:grouped_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group) }
        let(:root_used) { create(:taxonomy, organization:, name: { en: "Used Root" }) }
        let(:root_unused) { create(:taxonomy, organization:, name: { en: "Unused Root" }) }
        let(:child_used) { create(:taxonomy, organization:, parent: root_used, name: { en: "Active Item" }) }
        let(:child_unused) { create(:taxonomy, organization:, parent: root_unused, name: { en: "Orphan Item" }) }
        let(:filter_used) { create(:taxonomy_filter, root_taxonomy: root_used) }
        let(:filter_unused) { create(:taxonomy_filter, root_taxonomy: root_unused) }
        let!(:fi_used) { create(:taxonomy_filter_item, taxonomy_filter: filter_used, taxonomy_item: child_used) }
        let!(:fi_unused) { create(:taxonomy_filter_item, taxonomy_filter: filter_unused, taxonomy_item: child_unused) }
        let!(:taxonomization) { create(:taxonomization, taxonomy: child_used, taxonomizable: grouped_process) }

        it "hides the entire root taxonomy group with no processes" do
          block_cell.call
          groups = block_cell.taxonomy_filter_groups
          group_names = groups.map { |gr| gr[:name] }
          expect(group_names).to include("Used Root")
          expect(group_names).not_to include("Unused Root")
        end
      end

      context "when a child taxonomy has processes but its parent does not" do
        let!(:grouped_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group) }
        let(:root_taxonomy) { create(:taxonomy, organization:, name: { en: "Topics" }) }
        let(:parent_taxonomy) { create(:taxonomy, organization:, parent: root_taxonomy, name: { en: "Environment" }) }
        let(:child_taxonomy) { create(:taxonomy, organization:, parent: parent_taxonomy, name: { en: "Water" }) }
        let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
        let!(:fi_parent) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: parent_taxonomy) }
        let!(:fi_child) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_taxonomy) }
        let!(:taxonomization) { create(:taxonomization, taxonomy: child_taxonomy, taxonomizable: grouped_process) }

        it "keeps the parent item for hierarchy display" do
          block_cell.call
          groups = block_cell.taxonomy_filter_groups
          item_names = groups.first[:items].map { |it| it[:name] }
          expect(item_names).to include("Environment", "Water")
        end
      end

      context "when taxonomy filter is for a different manifest" do
        let!(:grouped_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group) }
        let(:root_taxonomy) { create(:taxonomy, organization:, name: { en: "Assembly Topics" }) }
        let(:child_taxonomy) { create(:taxonomy, organization:, parent: root_taxonomy, name: { en: "Governance" }) }
        let!(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:, participatory_space_manifests: ["assemblies"]) }
        let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_taxonomy) }

        it "does not render taxonomy filters for other manifests" do
          expect(subject).to have_no_content("Filter by:")
          expect(subject).to have_no_content("Assembly Topics")
        end
      end
    end
  end
end
