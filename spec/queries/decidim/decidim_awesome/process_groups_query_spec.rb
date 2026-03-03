# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe ProcessGroupsQuery do
    subject { described_class.new(process_group, user) }

    let(:user) { nil }

    let(:organization) { create(:organization) }
    let(:process_group) { create(:participatory_process_group, organization:) }

    let!(:active_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Active Process" }, start_date: 1.month.ago, end_date: 1.month.from_now) }
    let!(:past_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Past Process" }, start_date: 3.months.ago, end_date: 1.month.ago) }
    let!(:no_end_date_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Ongoing Process" }, start_date: 1.month.ago, end_date: nil) }
    let!(:ungrouped_process) { create(:participatory_process, :published, organization:, title: { en: "Ungrouped Process" }, start_date: 1.month.ago, end_date: 1.month.from_now) }
    let!(:unpublished_process) { create(:participatory_process, :unpublished, organization:, participatory_process_group: process_group, title: { en: "Draft Process" }) }

    describe "#base_relation" do
      it "returns only published processes belonging to the group" do
        titles = subject.base_relation.map { |process| process.title["en"] }
        expect(titles).to include("Active Process", "Past Process", "Ongoing Process")
        expect(titles).not_to include("Ungrouped Process", "Draft Process")
      end

      it "does not return processes from other groups" do
        other_group = create(:participatory_process_group, organization:)
        create(:participatory_process, :published, organization:, participatory_process_group: other_group, title: { en: "Other Group Process" })

        titles = subject.base_relation.map { |process| process.title["en"] }
        expect(titles).not_to include("Other Group Process")
      end
    end

    describe "#filtered_relation" do
      it "returns all processes when status is 'all'" do
        result = subject.filtered_relation(status: "all")
        expect(result).to include(active_process, past_process, no_end_date_process)
      end

      it "returns only active processes when status is 'active'" do
        result = subject.filtered_relation(status: "active")
        expect(result).to include(active_process, no_end_date_process)
        expect(result).not_to include(past_process)
      end

      it "returns only past processes when status is 'past'" do
        result = subject.filtered_relation(status: "past")
        expect(result).to include(past_process)
        expect(result).not_to include(active_process, no_end_date_process)
      end

      it "returns only upcoming processes when status is 'upcoming'" do
        upcoming = create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Future Process" }, start_date: 1.month.from_now, end_date: 2.months.from_now)
        result = subject.filtered_relation(status: "upcoming")
        expect(result).to include(upcoming)
        expect(result).not_to include(active_process, past_process)
      end

      it "returns all processes for unknown status" do
        result = subject.filtered_relation(status: "invalid")
        expect(result).to include(active_process, past_process, no_end_date_process)
      end

      context "with taxonomy filtering" do
        let(:root_taxonomy) { create(:taxonomy, organization:) }
        let(:child_a) { create(:taxonomy, organization:, parent: root_taxonomy) }
        let(:child_b) { create(:taxonomy, organization:, parent: root_taxonomy) }
        let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
        let!(:taxonomy_filter_item_a) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_a) }
        let!(:taxonomy_filter_item_b) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_b) }

        before do
          create(:taxonomization, taxonomy: child_a, taxonomizable: active_process)
          create(:taxonomization, taxonomy: child_b, taxonomizable: past_process)
        end

        it "filters by a single taxonomy (OR within group)" do
          result = subject.filtered_relation(taxonomy_ids: [child_a.id])
          expect(result).to include(active_process)
          expect(result).not_to include(past_process, no_end_date_process)
        end

        it "applies OR within the same group" do
          result = subject.filtered_relation(taxonomy_ids: [child_a.id, child_b.id])
          expect(result).to include(active_process, past_process)
          expect(result).not_to include(no_end_date_process)
        end

        context "with multiple taxonomy groups" do
          let(:second_root_taxonomy) { create(:taxonomy, organization:) }
          let(:child_c) { create(:taxonomy, organization:, parent: second_root_taxonomy) }
          let(:second_filter) { create(:taxonomy_filter, root_taxonomy: second_root_taxonomy) }
          let!(:second_filter_item) { create(:taxonomy_filter_item, taxonomy_filter: second_filter, taxonomy_item: child_c) }

          before do
            create(:taxonomization, taxonomy: child_c, taxonomizable: active_process)
          end

          it "applies AND between groups" do
            result = subject.filtered_relation(taxonomy_ids: [child_a.id, child_c.id])
            expect(result).to include(active_process)
            expect(result).not_to include(past_process, no_end_date_process)
          end

          it "returns nothing when AND condition is not met" do
            result = subject.filtered_relation(taxonomy_ids: [child_b.id, child_c.id])
            expect(result).to be_empty
          end
        end

        it "combines status and taxonomy filtering" do
          result = subject.filtered_relation(status: "active", taxonomy_ids: [child_a.id])
          expect(result).to include(active_process)
          expect(result).not_to include(past_process)
        end

        it "returns empty when status and taxonomy don't overlap" do
          result = subject.filtered_relation(status: "past", taxonomy_ids: [child_a.id])
          expect(result).to be_empty
        end

        it "ignores zero and blank taxonomy IDs" do
          result = subject.filtered_relation(taxonomy_ids: [0, ""])
          expect(result).to include(active_process, past_process, no_end_date_process)
        end

        it "deduplicates repeated taxonomy IDs" do
          result = subject.filtered_relation(taxonomy_ids: [child_a.id, child_a.id])
          expect(result).to include(active_process)
          expect(result).not_to include(past_process, no_end_date_process)
        end
      end

      it "returns an AR relation suitable for Kaminari" do
        result = subject.filtered_relation
        expect(result).to respond_to(:page)
        expect(result.page(1).per(2).size).to be <= 2
      end
    end

    describe "#status_counts" do
      it "returns correct counts for each status" do
        counts = subject.status_counts
        expect(counts["active"]).to eq(2)
        expect(counts["past"]).to eq(1)
        expect(counts["upcoming"]).to eq(0)
        expect(counts["all"]).to eq(3)
      end

      it "counts upcoming processes" do
        create(:participatory_process, :published, organization:, participatory_process_group: process_group, start_date: 1.month.from_now, end_date: 2.months.from_now)
        query = described_class.new(process_group, user)
        expect(query.status_counts["upcoming"]).to eq(1)
        expect(query.status_counts["all"]).to eq(4)
      end
    end

    describe "#taxonomy_filters" do
      let(:root_taxonomy) { create(:taxonomy, organization:, name: { en: "Topics" }) }
      let(:child_taxonomy) { create(:taxonomy, organization:, parent: root_taxonomy, name: { en: "Environment" }) }

      context "when filters exist for participatory_processes" do
        let!(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
        let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_taxonomy) }

        it "returns the taxonomy filters" do
          expect(subject.taxonomy_filters).to include(taxonomy_filter)
        end

        it "includes filter items with taxonomy items" do
          filter = subject.taxonomy_filters.first
          expect(filter.filter_items.first.taxonomy_item).to eq(child_taxonomy)
        end

        it "includes the root taxonomy" do
          filter = subject.taxonomy_filters.first
          expect(filter.root_taxonomy).to eq(root_taxonomy)
        end
      end

      context "when filters exist for a different manifest" do
        let!(:assembly_filter) { create(:taxonomy_filter, root_taxonomy:, participatory_space_manifests: ["assemblies"]) }

        it "does not return filters for other manifests" do
          expect(subject.taxonomy_filters).not_to include(assembly_filter)
        end
      end

      context "when no taxonomy filters exist" do
        it "returns an empty collection" do
          expect(subject.taxonomy_filters).to be_empty
        end
      end

      context "when filters belong to another organization" do
        let(:another_organization) { create(:organization) }
        let(:another_root) { create(:taxonomy, organization: another_organization) }
        let!(:another_filter) { create(:taxonomy_filter, root_taxonomy: another_root) }

        it "does not return filters from other organizations" do
          expect(subject.taxonomy_filters).not_to include(another_filter)
        end
      end
    end

    describe "#used_taxonomy_ids" do
      let(:root_taxonomy) { create(:taxonomy, organization:) }
      let(:child_a) { create(:taxonomy, organization:, parent: root_taxonomy) }
      let(:child_b) { create(:taxonomy, organization:, parent: root_taxonomy) }
      let(:child_unused) { create(:taxonomy, organization:, parent: root_taxonomy) }

      before do
        create(:taxonomization, taxonomy: child_a, taxonomizable: active_process)
        create(:taxonomization, taxonomy: child_b, taxonomizable: past_process)
      end

      it "returns taxonomy IDs used by processes in the group" do
        expect(subject.used_taxonomy_ids).to include(child_a.id, child_b.id)
      end

      it "does not include unused taxonomy IDs" do
        expect(subject.used_taxonomy_ids).not_to include(child_unused.id)
      end

      it "does not include taxonomies from ungrouped processes" do
        external_taxonomy = create(:taxonomy, organization:, parent: root_taxonomy)
        create(:taxonomization, taxonomy: external_taxonomy, taxonomizable: ungrouped_process)
        expect(subject.used_taxonomy_ids).not_to include(external_taxonomy.id)
      end

      it "does not include taxonomies from unpublished processes" do
        draft_taxonomy = create(:taxonomy, organization:, parent: root_taxonomy)
        create(:taxonomization, taxonomy: draft_taxonomy, taxonomizable: unpublished_process)
        expect(subject.used_taxonomy_ids).not_to include(draft_taxonomy.id)
      end

      it "returns a Set" do
        expect(subject.used_taxonomy_ids).to be_a(Set)
      end
    end

    describe "#available_taxonomy_groups" do
      let(:root_taxonomy) { create(:taxonomy, organization:, name: { en: "Topics" }) }
      let(:child_env) { create(:taxonomy, organization:, parent: root_taxonomy, name: { en: "Environment" }) }
      let(:child_transport) { create(:taxonomy, organization:, parent: root_taxonomy, name: { en: "Transport" }) }
      let(:child_unused) { create(:taxonomy, organization:, parent: root_taxonomy, name: { en: "Unused" }) }
      let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
      let!(:fi_env) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_env) }
      let!(:fi_transport) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_transport) }
      let!(:fi_unused) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_unused) }

      before do
        create(:taxonomization, taxonomy: child_env, taxonomizable: active_process)
        create(:taxonomization, taxonomy: child_transport, taxonomizable: past_process)
      end

      it "returns groups with root taxonomy objects" do
        groups = subject.available_taxonomy_groups
        expect(groups.length).to eq(1)
        expect(groups.first[:root_taxonomy]).to eq(root_taxonomy)
      end

      it "includes only taxonomy items used by processes" do
        items = subject.available_taxonomy_groups.first[:items]
        taxonomy_ids = items.map { |it| it[:taxonomy].id }
        expect(taxonomy_ids).to contain_exactly(child_env.id, child_transport.id)
      end

      it "excludes taxonomy items not used by any process" do
        items = subject.available_taxonomy_groups.first[:items]
        taxonomy_ids = items.map { |it| it[:taxonomy].id }
        expect(taxonomy_ids).not_to include(child_unused.id)
      end

      it "excludes groups where no items are used" do
        unused_root = create(:taxonomy, organization:, name: { en: "Empty" })
        unused_child = create(:taxonomy, organization:, parent: unused_root)
        unused_filter = create(:taxonomy_filter, root_taxonomy: unused_root)
        create(:taxonomy_filter_item, taxonomy_filter: unused_filter, taxonomy_item: unused_child)

        group_roots = subject.available_taxonomy_groups.map { |gr| gr[:root_taxonomy] }
        expect(group_roots).to include(root_taxonomy)
        expect(group_roots).not_to include(unused_root)
      end

      context "with hierarchical taxonomies" do
        let(:parent_tax) { create(:taxonomy, organization:, parent: root_taxonomy, name: { en: "Parent" }) }
        let(:child_deep) { create(:taxonomy, organization:, parent: parent_tax, name: { en: "Deep Child" }) }
        let!(:fi_parent) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: parent_tax) }
        let!(:fi_deep) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_deep) }

        before do
          create(:taxonomization, taxonomy: child_deep, taxonomizable: no_end_date_process)
        end

        it "keeps parent items when their children have processes" do
          items = subject.available_taxonomy_groups.first[:items]
          taxonomy_ids = items.map { |it| it[:taxonomy].id }
          expect(taxonomy_ids).to include(parent_tax.id, child_deep.id)
        end

        it "sorts children immediately after their parent" do
          items = subject.available_taxonomy_groups.first[:items]
          parent_idx = items.index { |it| it[:taxonomy].id == parent_tax.id }
          child_idx = items.index { |it| it[:taxonomy].id == child_deep.id }
          expect(child_idx).to eq(parent_idx + 1)
        end
      end
    end

    context "with another organization" do
      let(:another_organization) { create(:organization) }
      let(:another_group) { create(:participatory_process_group, organization: another_organization) }
      let!(:another_process) { create(:participatory_process, :published, organization: another_organization, participatory_process_group: another_group, title: { en: "Other Org Process" }) }

      it "does not include processes from other organizations" do
        titles = subject.base_relation.map { |process| process.title["en"] }
        expect(titles).not_to include("Other Org Process")
      end
    end
  end
end
