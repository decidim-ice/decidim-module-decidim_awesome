# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe AwesomeProcessGroupsQuery do
    subject { described_class.new(organization, user) }

    let(:user) { nil }

    let(:organization) { create(:organization) }
    let(:process_group) { create(:participatory_process_group, organization:) }

    let!(:active_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Active Process" }, start_date: 1.month.ago, end_date: 1.month.from_now) }
    let!(:past_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Past Process" }, start_date: 3.months.ago, end_date: 1.month.ago) }
    let!(:no_end_date_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Ongoing Process" }, start_date: 1.month.ago, end_date: nil) }
    let!(:ungrouped_process) { create(:participatory_process, :published, organization:, title: { en: "Ungrouped Process" }, start_date: 1.month.ago, end_date: 1.month.from_now) }
    let!(:unpublished_process) { create(:participatory_process, :unpublished, organization:, participatory_process_group: process_group, title: { en: "Draft Process" }) }

    describe "#results" do
      it "returns only published processes belonging to groups" do
        titles = subject.results.map { |item| item[:process].title["en"] }
        expect(titles).to include("Active Process", "Past Process", "Ongoing Process")
        expect(titles).not_to include("Ungrouped Process", "Draft Process")
      end

      it "assigns correct status to active processes" do
        active_item = subject.results.find { |item| item[:process] == active_process }
        expect(active_item[:status]).to eq("active")
      end

      it "assigns correct status to past processes" do
        past_item = subject.results.find { |item| item[:process] == past_process }
        expect(past_item[:status]).to eq("past")
      end

      it "treats processes without end_date as active" do
        ongoing_item = subject.results.find { |item| item[:process] == no_end_date_process }
        expect(ongoing_item[:status]).to eq("active")
      end

      it "assigns correct status to upcoming processes" do
        upcoming = create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Future Process" }, start_date: 1.month.from_now, end_date: 2.months.from_now)
        item = subject.results.find { |i| i[:process] == upcoming }
        expect(item[:status]).to eq("upcoming")
      end

      it "includes taxonomy_ids for each process" do
        root_taxonomy = create(:taxonomy, organization:)
        child_taxonomy = create(:taxonomy, organization:, parent: root_taxonomy)
        create(:taxonomization, taxonomy: child_taxonomy, taxonomizable: active_process)

        active_item = subject.results.find { |item| item[:process] == active_process }
        expect(active_item[:taxonomy_ids]).to include(child_taxonomy.id)
      end

      it "returns empty taxonomy_ids when process has no taxonomies" do
        item = subject.results.find { |i| i[:process] == past_process }
        expect(item[:taxonomy_ids]).to be_empty
      end

      it "falls back to active status when process has no dates" do
        no_dates = create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "No Dates Process" }, start_date: nil, end_date: nil)
        item = subject.results.find { |i| i[:process] == no_dates }
        expect(item[:status]).to eq("active")
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

    context "with another organization" do
      let(:another_organization) { create(:organization) }
      let(:another_group) { create(:participatory_process_group, organization: another_organization) }
      let!(:another_process) { create(:participatory_process, :published, organization: another_organization, participatory_process_group: another_group, title: { en: "Other Org Process" }) }

      it "does not include processes from other organizations" do
        titles = subject.results.map { |item| item[:process].title["en"] }
        expect(titles).not_to include("Other Org Process")
      end
    end
  end
end
