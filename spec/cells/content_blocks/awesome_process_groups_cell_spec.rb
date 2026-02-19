# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe ContentBlocks::AwesomeProcessGroupsCell, type: :cell do
    subject { cell(content_block.cell, content_block).call }

    let(:organization) { create(:organization) }
    let(:content_block) { create(:content_block, organization:, manifest_name: :awesome_process_groups, scope_name: :homepage, settings:) }
    let(:settings) { {} }
    let(:process_group) { create(:participatory_process_group, organization:) }

    controller Decidim::PagesController

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    context "when there are no processes belonging to groups" do
      it "does not render content" do
        expect(subject).to have_no_content("Process Groups Extended")
      end
    end

    context "when there are processes belonging to groups" do
      let!(:grouped_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Climate Action Plan" }) }

      it "renders the default title" do
        expect(subject).to have_content("Process Groups Extended")
      end

      it "renders the process card" do
        expect(subject).to have_content("Climate Action Plan")
      end

      it "renders the status filter buttons" do
        expect(subject).to have_content("Active")
        expect(subject).to have_content("Past")
        expect(subject).to have_content("All")
      end

      it "renders the status label" do
        expect(subject).to have_content("Status:")
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
        expect(subject).to have_no_content("Process Groups Extended")
      end
    end

    context "with active and past processes" do
      let!(:active_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Current Project" }, start_date: 1.month.ago, end_date: 1.month.from_now) }
      let!(:past_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Finished Project" }, start_date: 3.months.ago, end_date: 1.month.ago) }

      it "renders both processes" do
        expect(subject).to have_content("Current Project")
        expect(subject).to have_content("Finished Project")
      end

      it "shows counts in filter buttons" do
        expect(subject.text).to include("Active")
        expect(subject.text).to include("Past")
        expect(subject.text).to include("All")
        cell_instance = cell(content_block.cell, content_block)
        expect(cell_instance.count_for("active")).to eq(1)
        expect(cell_instance.count_for("past")).to eq(1)
        expect(cell_instance.count_for("all")).to eq(2)
      end
    end

    context "with another organization" do
      let(:another_organization) { create(:organization) }
      let(:another_group) { create(:participatory_process_group, organization: another_organization) }
      let!(:grouped_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Org1 Process" }) }
      let!(:another_process) { create(:participatory_process, :published, organization: another_organization, participatory_process_group: another_group, title: { en: "Org2 Process" }) }

      it "only shows processes from the current organization" do
        expect(subject).to have_content("Org1 Process")
        expect(subject).to have_no_content("Org2 Process")
      end
    end

    context "when process is not published" do
      let!(:unpublished_process) { create(:participatory_process, :unpublished, organization:, participatory_process_group: process_group, title: { en: "Draft Process" }) }

      it "does not show unpublished processes" do
        expect(subject).to have_no_content("Draft Process")
      end
    end

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
        cell_instance = cell(content_block.cell, content_block)
        cell_instance.call
        expect(cell_instance.taxonomy_filters_available?).to be(true)
      end

      it "builds correct taxonomy filter groups structure" do
        cell_instance = cell(content_block.cell, content_block)
        cell_instance.call
        groups = cell_instance.taxonomy_filter_groups
        expect(groups.length).to eq(1)
        expect(groups.first[:name]).to eq("Topics")
        expect(groups.first[:root_id]).to eq(root_taxonomy.id)
        expect(groups.first[:items].first[:name]).to eq("Environment")
        expect(groups.first[:items].first[:id]).to eq(child_taxonomy.id)
      end

      it "includes taxonomy_ids in process items" do
        cell_instance = cell(content_block.cell, content_block)
        cell_instance.call
        item = cell_instance.process_items.find { |i| i[:process] == grouped_process }
        expect(item[:taxonomy_ids]).to include(child_taxonomy.id)
      end
    end

    context "when taxonomy filters have multiple groups" do
      let!(:grouped_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Multi Tax Process" }) }
      let(:root_taxonomy_a) { create(:taxonomy, organization:, name: { en: "Scope" }) }
      let(:root_taxonomy_b) { create(:taxonomy, organization:, name: { en: "Category" }) }
      let(:child_a) { create(:taxonomy, organization:, parent: root_taxonomy_a, name: { en: "Urban" }) }
      let(:child_b) { create(:taxonomy, organization:, parent: root_taxonomy_b, name: { en: "Health" }) }
      let(:filter_a) { create(:taxonomy_filter, root_taxonomy: root_taxonomy_a) }
      let(:filter_b) { create(:taxonomy_filter, root_taxonomy: root_taxonomy_b) }
      let!(:filter_item_a) { create(:taxonomy_filter_item, taxonomy_filter: filter_a, taxonomy_item: child_a) }
      let!(:filter_item_b) { create(:taxonomy_filter_item, taxonomy_filter: filter_b, taxonomy_item: child_b) }

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
      let!(:grouped_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "No Tax Process" }) }

      it "does not render the filter by label" do
        expect(subject).to have_no_content("Filter by:")
      end

      it "reports taxonomy filters as not available" do
        cell_instance = cell(content_block.cell, content_block)
        cell_instance.call
        expect(cell_instance.taxonomy_filters_available?).to be(false)
      end
    end

    context "when taxonomy filter exists but has no items" do
      let!(:grouped_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Empty Filter Process" }) }
      let(:root_taxonomy) { create(:taxonomy, organization:, name: { en: "Empty Root" }) }
      let!(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }

      it "does not render the filter by label" do
        expect(subject).to have_no_content("Filter by:")
      end

      it "reports taxonomy filters as not available" do
        cell_instance = cell(content_block.cell, content_block)
        cell_instance.call
        expect(cell_instance.taxonomy_filters_available?).to be(false)
      end
    end

    context "when taxonomy filter is for a different manifest" do
      let!(:grouped_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Wrong Manifest Process" }) }
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
