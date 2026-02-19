# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe AwesomeProcessGroupsQuery do
    subject { described_class.new(organization) }

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
    end

    describe "#active" do
      it "returns only active processes" do
        titles = subject.active.map { |p| p.title["en"] }
        expect(titles).to include("Active Process", "Ongoing Process")
        expect(titles).not_to include("Past Process")
      end
    end

    describe "#past" do
      it "returns only past processes" do
        titles = subject.past.map { |p| p.title["en"] }
        expect(titles).to include("Past Process")
        expect(titles).not_to include("Active Process", "Ongoing Process")
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
