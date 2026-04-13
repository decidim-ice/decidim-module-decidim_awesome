# frozen_string_literal: true

require "spec_helper"

describe "Public homepage shows Awesome Processes block" do
  let(:organization) { create(:organization) }

  let!(:content_block) { create(:content_block, organization:, manifest_name: :awesome_processes, scope_name: :homepage, settings:) }
  let(:settings) { {} }
  let!(:process_group) { create(:participatory_process_group, organization:) }
  let!(:active_process) { create(:participatory_process, :active, :published, organization:) }
  let!(:grouped_process) { create(:participatory_process, :active, :published, organization:, participatory_process_group: process_group) }
  let!(:past_process) { create(:participatory_process, :past, :published, organization:) }

  before do
    switch_to_host(organization.host)
  end

  context "when block is active with default settings" do
    it "displays active processes on homepage" do
      visit decidim.root_path
      expect(page).to have_content(translated(active_process.title))
      expect(page).to have_content(translated(grouped_process.title))
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

    it "shows only processes without a group" do
      visit decidim.root_path
      expect(page).to have_content(translated(active_process.title))
      expect(page).to have_no_content(translated(grouped_process.title))
    end
  end

  context "when process_type is 'groups'" do
    let(:settings) { { process_type: "groups" } }

    it "shows individual processes that belong to groups" do
      visit decidim.root_path
      expect(page).to have_content(translated(grouped_process.title))
      expect(page).to have_no_content(translated(active_process.title))
    end

    context "when restricted to a specific group" do
      let!(:other_group) { create(:participatory_process_group, organization:) }
      let!(:other_grouped) { create(:participatory_process, :active, :published, organization:, participatory_process_group: other_group) }
      let(:settings) { { process_type: "groups", process_group_id: process_group.id } }

      it "shows only processes from that group" do
        visit decidim.root_path
        expect(page).to have_content(translated(grouped_process.title))
        expect(page).to have_no_content(translated(other_grouped.title))
        expect(page).to have_no_content(translated(active_process.title))
      end
    end
  end

  context "when process_type is 'all'" do
    let(:settings) { { process_type: "all", max_results: 10 } }

    it "shows all processes regardless of group" do
      visit decidim.root_path
      expect(page).to have_content(translated(active_process.title))
      expect(page).to have_content(translated(grouped_process.title))
    end

    context "when restricted to a specific group" do
      let!(:other_group) { create(:participatory_process_group, organization:) }
      let!(:other_grouped) { create(:participatory_process, :active, :published, organization:, participatory_process_group: other_group) }
      let(:settings) { { process_type: "all", process_group_id: process_group.id, max_results: 10 } }

      it "shows processes from that group and ungrouped processes" do
        visit decidim.root_path
        expect(page).to have_content(translated(grouped_process.title))
        expect(page).to have_content(translated(active_process.title))
        expect(page).to have_no_content(translated(other_grouped.title))
      end
    end
  end

  context "when process_status is 'all'" do
    let(:settings) { { process_status: "all" } }

    it "shows both active and past processes" do
      visit decidim.root_path
      expect(page).to have_content(translated(active_process.title))
      expect(page).to have_content(translated(past_process.title))
    end
  end

  context "when process_status is 'past'" do
    let(:settings) { { process_status: "past" } }

    it "shows only past processes" do
      visit decidim.root_path
      expect(page).to have_content(translated(past_process.title))
      expect(page).to have_no_content(translated(active_process.title))
    end
  end

  context "when process_status is 'upcoming'" do
    let!(:upcoming_process) { create(:participatory_process, :upcoming, :published, organization:) }
    let(:settings) { { process_status: "upcoming" } }

    it "shows only upcoming processes" do
      visit decidim.root_path
      expect(page).to have_content(translated(upcoming_process.title))
      expect(page).to have_no_content(translated(active_process.title))
      expect(page).to have_no_content(translated(past_process.title))
    end
  end

  context "when max_results is 1" do
    let(:settings) { { max_results: 1 } }

    it "shows only 1 item" do
      visit decidim.root_path
      expect(page).to have_css(".card__grid-home > *", count: 1)
    end
  end

  context "when selection_criteria is manual" do
    let(:settings) do
      {
        selection_criteria: "manual",
        selected_ids: [active_process.id.to_s]
      }
    end

    it "shows only selected processes" do
      visit decidim.root_path
      expect(page).to have_content(translated(active_process.title))
    end

    context "when restricted to a specific group (type: groups)" do
      let!(:other_process) { create(:participatory_process, :active, :published, organization:) }
      let(:settings) do
        {
          selection_criteria: "manual",
          process_type: "groups",
          process_group_id: process_group.id,
          selected_ids: [grouped_process.id.to_s, other_process.id.to_s]
        }
      end

      it "shows only processes from the restricted group" do
        visit decidim.root_path
        expect(page).to have_content(translated(grouped_process.title))
        expect(page).to have_no_content(translated(other_process.title))
      end
    end
  end

  context "when no matching processes exist" do
    let(:settings) { { process_type: "processes" } }

    before do
      Decidim::ParticipatoryProcess.where(organization:).destroy_all
    end

    it "does not show the block section" do
      visit decidim.root_path
      expect(page).to have_no_css(".card__grid-home")
    end
  end

  context "when block is inactive" do
    before do
      content_block.destroy!
    end

    it "does not show the block on homepage" do
      visit decidim.root_path
      expect(page).to have_no_content("Participatory processes")
    end
  end

  it "shows 'See all processes' link" do
    visit decidim.root_path
    expect(page).to have_link("See all processes")
  end
end
