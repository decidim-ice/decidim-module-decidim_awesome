# frozen_string_literal: true

require "spec_helper"

describe "Public homepage shows Awesome Processes block" do
  let(:organization) { create(:organization) }

  let!(:content_block) { create(:content_block, organization:, manifest_name: :awesome_processes, scope_name: :homepage, settings:) }
  let(:settings) { {} }
  let!(:active_process) { create(:participatory_process, :active, :published, organization:) }
  let!(:past_process) { create(:participatory_process, :past, :published, organization:) }
  let!(:process_group) { create(:participatory_process_group, organization:) }

  before do
    switch_to_host(organization.host)
  end

  context "when block is active with active processes" do
    it "displays processes on homepage" do
      visit decidim.root_path
      expect(page).to have_content(translated(active_process.title))
    end
  end

  context "when custom title is set" do
    let(:settings) { { "title" => { "en" => "Featured Projects" } } }

    it "shows the custom title" do
      visit decidim.root_path
      expect(page).to have_css("h2", text: "Featured Projects")
    end
  end

  context "when process_type is 'processes'" do
    let(:settings) { { process_type: "processes" } }

    it "shows only processes, not groups" do
      visit decidim.root_path
      expect(page).to have_content(translated(active_process.title))
      expect(page).to have_no_content(translated(process_group.title))
    end
  end

  context "when process_type is 'groups'" do
    let(:settings) { { process_type: "groups" } }

    it "shows only groups" do
      visit decidim.root_path
      expect(page).to have_content(translated(process_group.title))
      expect(page).to have_no_content(translated(active_process.title))
    end
  end

  context "when process_type is 'all' (mixed)" do
    let(:settings) { { process_type: "all", max_results: 10 } }

    it "shows both processes and groups" do
      visit decidim.root_path
      expect(page).to have_content(translated(active_process.title))
      expect(page).to have_content(translated(process_group.title))
    end
  end

  context "when process_status is 'all'" do
    let(:settings) { { process_type: "processes", process_status: "all" } }

    it "shows both active and past processes" do
      visit decidim.root_path
      expect(page).to have_content(translated(active_process.title))
      expect(page).to have_content(translated(past_process.title))
    end
  end

  context "when process_status is 'past'" do
    let(:settings) { { process_type: "processes", process_status: "past" } }

    it "shows only past processes" do
      visit decidim.root_path
      expect(page).to have_content(translated(past_process.title))
      expect(page).to have_no_content(translated(active_process.title))
    end
  end

  context "when max_results is 1" do
    let(:settings) { { max_results: 1 } }
    let!(:another_active_process) { create(:participatory_process, :active, :published, organization:) }

    it "shows only 1 item" do
      visit decidim.root_path
      expect(page).to have_css(".card__grid-home > *", count: 1)
      expect(page).to have_content(translated(active_process.title))
      expect(page).to have_no_content(translated(another_active_process.title))
    end
  end

  context "when selection_criteria is manual" do
    let(:settings) do
      {
        selection_criteria: "manual",
        selected_ids: ["process_#{active_process.id}"]
      }
    end

    it "shows only selected processes" do
      visit decidim.root_path
      expect(page).to have_content(translated(active_process.title))
    end
  end

  context "when no matching processes exist" do
    let(:settings) { { process_type: "processes" } }

    before do
      Decidim::ParticipatoryProcess.where(organization:).destroy_all
    end

    it "does not show the block section or any process content" do
      visit decidim.root_path
      expect(page).to have_no_css(".card__grid-home")
      expect(page).to have_no_content(translated(active_process.title))
    end
  end

  context "when block is inactive" do
    before do
      content_block.destroy!
    end

    it "does not show the block on homepage" do
      visit decidim.root_path
      expect(page).to have_no_content("Last processes")
    end
  end

  context "when 'See all processes' link is present" do
    it "links to participatory processes index" do
      visit decidim.root_path
      expect(page).to have_link("See all processes")
    end
  end
end
