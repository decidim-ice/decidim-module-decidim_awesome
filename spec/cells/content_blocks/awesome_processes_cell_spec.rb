# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe ContentBlocks::AwesomeProcessesCell, type: :cell do
    subject { cell(content_block.cell, content_block).call }

    let(:organization) { create(:organization) }
    let(:content_block) { create(:content_block, organization:, manifest_name: :awesome_processes, scope_name: :homepage, settings:) }
    let(:settings) { {} }

    let!(:process_group) { create(:participatory_process_group, organization:) }
    let!(:active_process) { create(:participatory_process, :active, :published, organization:) }
    let!(:grouped_process) { create(:participatory_process, :active, :published, organization:, participatory_process_group: process_group) }
    let!(:past_process) { create(:participatory_process, :past, :published, organization:) }

    controller Decidim::PagesController

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "renders active processes" do
      expect(subject).to have_css(".card__grid-home")
      expect(subject).to have_content(translated(active_process.title))
      expect(subject).to have_content(translated(grouped_process.title))
    end

    it "does not show past processes with default settings" do
      expect(subject).to have_no_content(translated(past_process.title))
    end

    it "shows the default title" do
      expect(subject).to have_css("h2", text: "Participatory processes")
    end

    context "when a custom title is set" do
      let(:settings) { { "title" => { "en" => "Featured Projects" } } }

      it "shows the custom title" do
        expect(subject).to have_css("h2", text: "Featured Projects")
      end
    end

    context "when process_type is 'processes'" do
      let(:settings) { { process_type: "processes" } }

      it "shows only processes without a group" do
        expect(subject).to have_content(translated(active_process.title))
        expect(subject).to have_no_content(translated(grouped_process.title))
      end
    end

    context "when process_type is 'groups'" do
      let(:settings) { { process_type: "groups" } }

      it "shows only processes with a group" do
        expect(subject).to have_content(translated(grouped_process.title))
        expect(subject).to have_no_content(translated(active_process.title))
      end

      context "when restricted to a specific group" do
        let!(:other_group) { create(:participatory_process_group, organization:) }
        let!(:other_grouped) { create(:participatory_process, :active, :published, organization:, participatory_process_group: other_group) }
        let(:settings) { { process_type: "groups", process_group_id: process_group.id } }

        it "shows only processes from that group" do
          expect(subject).to have_content(translated(grouped_process.title))
          expect(subject).to have_no_content(translated(other_grouped.title))
        end
      end
    end

    context "when process_status is 'all'" do
      let(:settings) { { process_status: "all" } }

      it "shows both active and past processes" do
        expect(subject).to have_content(translated(active_process.title))
        expect(subject).to have_content(translated(past_process.title))
      end
    end

    context "when process_status is 'past'" do
      let(:settings) { { process_status: "past" } }

      it "shows only past processes" do
        expect(subject).to have_content(translated(past_process.title))
        expect(subject).to have_no_content(translated(active_process.title))
      end
    end

    context "when max_results limits output" do
      let(:settings) { { max_results: 1 } }

      it "limits the number of displayed items" do
        expect(subject.all(".card__grid-home > *").count).to be <= 1
      end
    end

    context "when filtering by process group (type: all)" do
      let(:settings) { { process_group_id: process_group.id } }

      it "shows grouped processes from that group and ungrouped processes" do
        expect(subject).to have_content(translated(grouped_process.title))
        expect(subject).to have_content(translated(active_process.title))
      end
    end

    context "when filtering by process group (type: groups)" do
      let(:settings) { { process_type: "groups", process_group_id: process_group.id } }

      it "shows only processes from the specified group" do
        expect(subject).to have_content(translated(grouped_process.title))
        expect(subject).to have_no_content(translated(active_process.title))
      end
    end

    context "when selection_criteria is 'manual'" do
      let(:settings) do
        {
          selection_criteria: "manual",
          selected_ids: [active_process.id.to_s, past_process.id.to_s]
        }
      end

      it "shows the manually selected processes" do
        expect(subject).to have_content(translated(active_process.title))
        expect(subject).to have_content(translated(past_process.title))
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

    describe "#max_results" do
      let(:settings) { { max_results: 3 } }

      it "returns the configured max_results from settings" do
        cell_instance = cell(content_block.cell, content_block)
        expect(cell_instance.max_results).to eq(3)
      end
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
