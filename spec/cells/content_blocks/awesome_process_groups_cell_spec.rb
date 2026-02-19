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
  end
end
