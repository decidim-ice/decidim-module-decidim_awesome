# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe ContentBlocks::AwesomeProcessesCell, type: :cell do
    subject { cell(content_block.cell, content_block).call }

    let(:organization) { create(:organization) }
    let(:content_block) { create(:content_block, organization:, manifest_name: :awesome_processes, scope_name: :homepage, settings:) }
    let(:settings) { {} }

    let!(:active_process) { create(:participatory_process, :active, :published, organization:) }
    let!(:past_process) { create(:participatory_process, :past, :published, organization:) }
    let!(:process_group) { create(:participatory_process_group, organization:) }

    controller Decidim::PagesController

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "renders active processes" do
      expect(subject).to have_css(".card__grid-home")
      expect(subject).to have_content(translated(active_process.title))
    end

    it "does not show past processes with default settings" do
      expect(subject).to have_no_content(translated(past_process.title))
    end

    it "shows the default title" do
      expect(subject).to have_css("h2", text: "Last processes")
    end

    context "when a custom title is set" do
      let(:settings) do
        { "title" => { "en" => "Featured Projects" } }
      end

      it "shows the custom title" do
        expect(subject).to have_css("h2", text: "Featured Projects")
      end
    end

    context "when process_type is 'processes'" do
      let(:settings) { { process_type: "processes" } }

      it "shows only processes" do
        expect(subject).to have_content(translated(active_process.title))
        expect(subject).to have_no_content(translated(process_group.title))
      end
    end

    context "when process_type is 'groups'" do
      let(:settings) { { process_type: "groups" } }

      it "shows only process groups" do
        expect(subject).to have_content(translated(process_group.title))
        expect(subject).to have_no_content(translated(active_process.title))
      end
    end

    context "when max_results limits output" do
      let(:settings) { { max_results: 1 } }

      let!(:another_active_process) { create(:participatory_process, :active, :published, organization:) }

      it "limits the number of displayed items" do
        expect(subject.all(".card__grid-home > *").count).to be <= 1
      end
    end

    context "when filtering by process group" do
      let!(:grouped_process) { create(:participatory_process, :active, :published, organization:, participatory_process_group: process_group) }
      let!(:ungrouped_process) { create(:participatory_process, :active, :published, organization:) }
      let(:settings) { { process_type: "processes", process_group_id: process_group.id } }

      it "shows only processes from the specified group" do
        expect(subject).to have_content(translated(grouped_process.title))
        expect(subject).to have_no_content(translated(ungrouped_process.title))
      end
    end

    context "when selection_criteria is 'manual'" do
      let(:settings) do
        {
          selection_criteria: "manual",
          selected_ids: ["process_#{active_process.id}", "process_#{past_process.id}"]
        }
      end

      it "shows the manually selected processes" do
        expect(subject).to have_content(translated(active_process.title))
        expect(subject).to have_content(translated(past_process.title))
      end
    end

    context "when manual selection includes groups" do
      let(:settings) do
        {
          selection_criteria: "manual",
          selected_ids: ["group_#{process_group.id}"]
        }
      end

      it "shows the selected groups" do
        expect(subject).to have_content(translated(process_group.title))
      end
    end

    context "with another organization" do
      let(:another_organization) { create(:organization) }
      let(:another_content_block) { create(:content_block, organization: another_organization, manifest_name: :awesome_processes, scope_name: :homepage, settings: {}) }
      let!(:another_process) { create(:participatory_process, :active, :published, organization: another_organization) }

      before do
        allow(controller).to receive(:current_organization).and_return(another_organization)
      end

      it "only shows processes from its own organization" do
        result = cell(another_content_block.cell, another_content_block).call
        expect(result).to have_content(translated(another_process.title))
        expect(result).to have_no_content(translated(active_process.title))
      end
    end

    it "shows the 'See all processes' link" do
      expect(subject).to have_link("See all processes")
    end

    context "when no processes match" do
      it "does not render content" do
        org_without_processes = create(:organization)
        block = create(:content_block, organization: org_without_processes, manifest_name: :awesome_processes, scope_name: :homepage, settings: { process_type: "processes" })
        allow(controller).to receive(:current_organization).and_return(org_without_processes)
        result = cell(block.cell, block).call
        expect(result).to have_no_css(".card__grid-home")
      end
    end
  end
end
