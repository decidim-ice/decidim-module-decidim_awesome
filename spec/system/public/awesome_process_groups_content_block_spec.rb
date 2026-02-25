# frozen_string_literal: true

require "spec_helper"

describe "Awesome Process Groups content block on group landing page" do
  let(:organization) { create(:organization) }
  let(:process_group) { create(:participatory_process_group, organization:) }
  let!(:content_block) { create(:content_block, organization:, manifest_name: :awesome_process_groups, scope_name: :participatory_process_group_homepage, scoped_resource_id: process_group.id) }

  let!(:active_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Test Active Process" }, start_date: 1.month.ago, end_date: 1.month.from_now) }
  let!(:past_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Test Past Process" }, start_date: 3.months.ago, end_date: 1.month.ago) }
  let!(:upcoming_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Test Upcoming Process" }, start_date: 1.month.from_now, end_date: 2.months.from_now) }

  before do
    switch_to_host(organization.host)
  end

  def visit_group_page
    visit decidim_participatory_processes.participatory_process_group_path(process_group)
  end

  it "renders the content block with default title" do
    visit_group_page
    within "[data-process-groups-filter]" do
      expect(page).to have_content("Participatory processes")
    end
  end

  it "renders all process cards" do
    visit_group_page
    within "[data-process-groups-filter]" do
      expect(page).to have_content("Test Active Process")
      expect(page).to have_content("Test Past Process")
      expect(page).to have_content("Test Upcoming Process")
    end
  end

  it "renders the status label and filter tabs as links" do
    visit_group_page
    within "[data-process-groups-filter]" do
      expect(page).to have_content("Status:")
      expect(page).to have_link("Active (1)")
      expect(page).to have_link("Past (1)")
      expect(page).to have_link("Upcoming (1)")
      expect(page).to have_link("All (3)")
    end
  end

  it "does not show processes from other groups" do
    other_group = create(:participatory_process_group, organization:)
    create(:participatory_process, :published, organization:, participatory_process_group: other_group, title: { en: "Other Group Process" })

    visit_group_page
    within "[data-process-groups-filter]" do
      expect(page).to have_no_content("Other Group Process")
    end
  end

  context "when filtering by status" do
    it "shows only active processes when clicking Active" do
      visit_group_page
      within "[data-process-groups-filter]" do
        click_on "Active (1)"
      end
      expect(page).to have_current_path(/status=active/)
      within "[data-process-groups-filter]" do
        expect(page).to have_content("Test Active Process")
        expect(page).to have_no_content("Test Past Process")
        expect(page).to have_no_content("Test Upcoming Process")
      end
    end

    it "shows only past processes when clicking Past" do
      visit_group_page
      within "[data-process-groups-filter]" do
        click_on "Past (1)"
      end
      expect(page).to have_current_path(/status=past/)
      within "[data-process-groups-filter]" do
        expect(page).to have_content("Test Past Process")
        expect(page).to have_no_content("Test Active Process")
        expect(page).to have_no_content("Test Upcoming Process")
      end
    end

    it "shows only upcoming processes when clicking Upcoming" do
      visit_group_page
      within "[data-process-groups-filter]" do
        click_on "Upcoming (1)"
      end
      expect(page).to have_current_path(/status=upcoming/)
      within "[data-process-groups-filter]" do
        expect(page).to have_content("Test Upcoming Process")
        expect(page).to have_no_content("Test Active Process")
        expect(page).to have_no_content("Test Past Process")
      end
    end

    it "shows all processes when clicking All" do
      visit_group_page
      within "[data-process-groups-filter]" do
        click_on "Active (1)"
      end
      expect(page).to have_no_content("Test Past Process")
      within "[data-process-groups-filter]" do
        click_on "All (3)"
      end
      within "[data-process-groups-filter]" do
        expect(page).to have_content("Test Active Process")
        expect(page).to have_content("Test Past Process")
        expect(page).to have_content("Test Upcoming Process")
      end
    end

    it "preserves tab counts regardless of status filter" do
      visit_group_page
      within "[data-process-groups-filter]" do
        click_on "Active (1)"
      end
      within "[data-process-groups-filter]" do
        expect(page).to have_link("Active (1)")
        expect(page).to have_link("Past (1)")
        expect(page).to have_link("Upcoming (1)")
        expect(page).to have_link("All (3)")
      end
    end
  end

  it "displays the results count" do
    visit_group_page
    within "[data-process-groups-filter]" do
      expect(page).to have_content("3 processes found")
    end
  end

  it "updates the results count when filtering by status" do
    visit_group_page
    within "[data-process-groups-filter]" do
      click_on "Active (1)"
    end
    within "[data-process-groups-filter]" do
      expect(page).to have_content("1 process found")
    end
  end

  context "when no taxonomy filters exist" do
    it "does not render the filter by label" do
      visit_group_page
      within "[data-process-groups-filter]" do
        expect(page).to have_no_content("Filter by:")
      end
    end
  end

  context "when taxonomy filters are available" do
    let(:root_taxonomy) { create(:taxonomy, organization:, name: { en: "Topics" }) }
    let(:child_environment) { create(:taxonomy, organization:, parent: root_taxonomy, name: { en: "Environment" }) }
    let(:child_transport) { create(:taxonomy, organization:, parent: root_taxonomy, name: { en: "Transport" }) }
    let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
    let!(:filter_item_env) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_environment) }
    let!(:filter_item_trans) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_transport) }
    let!(:taxonomization_env) { create(:taxonomization, taxonomy: child_environment, taxonomizable: active_process) }
    let!(:taxonomization_trans) { create(:taxonomization, taxonomy: child_transport, taxonomizable: past_process) }

    it "renders the filter by label and taxonomy group" do
      visit_group_page
      within "[data-process-groups-filter]" do
        expect(page).to have_content("Filter by:")
        expect(page).to have_content("Topics")
      end
    end

    it "opens the dropdown and shows taxonomy items when clicking the trigger" do
      visit_group_page
      within "[data-process-groups-filter]" do
        click_on "Topics"
        expect(page).to have_content("Environment")
        expect(page).to have_content("Transport")
      end
    end

    it "closes dropdown when clicking outside" do
      visit_group_page
      within "[data-process-groups-filter]" do
        click_on "Topics"
        expect(page).to have_content("Environment")
        expect(page).to have_content("Transport")

        find("h2").click

        expect(page).to have_no_content("Environment")
        expect(page).to have_no_content("Transport")
      end
    end

    it "filters processes by taxonomy when checking a checkbox" do
      visit_group_page
      within "[data-process-groups-filter]" do
        click_on "Topics"
        check "Environment"
      end
      expect(page).to have_current_path(/taxonomy_ids/)
      within "[data-process-groups-filter]" do
        expect(page).to have_content("Test Active Process")
        expect(page).to have_no_content("Test Past Process")
      end
    end

    it "shows active filter tags when a taxonomy is selected" do
      visit_group_page
      within "[data-process-groups-filter]" do
        click_on "Topics"
        check "Environment"
      end
      within "[data-process-groups-filter]" do
        expect(page).to have_content("Environment")
      end
    end

    it "removes filter tag and restores processes when clicking the remove button" do
      visit_group_page
      within "[data-process-groups-filter]" do
        click_on "Topics"
        check "Environment"
      end
      within "[data-process-groups-filter]" do
        expect(page).to have_no_content("Test Past Process")
        find("button[data-remove-tag]").click
      end
      within "[data-process-groups-filter]" do
        expect(page).to have_content("Test Active Process")
        expect(page).to have_content("Test Past Process")
      end
    end

    it "combines status and taxonomy filters" do
      visit_group_page
      within "[data-process-groups-filter]" do
        click_on "Topics"
        check "Transport"
      end
      within "[data-process-groups-filter]" do
        expect(page).to have_content("Test Past Process")
        expect(page).to have_no_content("Test Active Process")
        click_on "Active (1)"
      end
      within "[data-process-groups-filter]" do
        expect(page).to have_no_content("Test Past Process")
        expect(page).to have_no_content("Test Active Process")
      end
    end

    it "applies OR within same taxonomy group when selecting multiple items" do
      visit_group_page
      within "[data-process-groups-filter]" do
        click_on "Topics"
        check "Environment"
      end
      within "[data-process-groups-filter]" do
        click_on "Topics"
        check "Transport"
      end
      within "[data-process-groups-filter]" do
        expect(page).to have_content("Test Active Process")
        expect(page).to have_content("Test Past Process")
      end
    end

    it "removes one tag while preserving other taxonomy filters" do
      visit_group_page
      within "[data-process-groups-filter]" do
        click_on "Topics"
        check "Environment"
      end
      within "[data-process-groups-filter]" do
        click_on "Topics"
        check "Transport"
      end
      within "[data-process-groups-filter]" do
        expect(page).to have_content("Test Active Process")
        expect(page).to have_content("Test Past Process")
        within("[data-tag-for='#{child_environment.id}']") do
          find("button[data-remove-tag]").click
        end
      end
      within "[data-process-groups-filter]" do
        expect(page).to have_no_content("Test Active Process")
        expect(page).to have_content("Test Past Process")
      end
    end

    it "preserves taxonomy filter when switching status tabs" do
      visit_group_page
      within "[data-process-groups-filter]" do
        click_on "Topics"
        check "Environment"
      end
      within "[data-process-groups-filter]" do
        expect(page).to have_content("Test Active Process")
        expect(page).to have_no_content("Test Past Process")
        click_on "Past (1)"
      end
      within "[data-process-groups-filter]" do
        expect(page).to have_no_content("Test Active Process")
        expect(page).to have_no_content("Test Past Process")
      end
    end

    it "shows no process cards when filters match nothing" do
      visit_group_page
      within "[data-process-groups-filter]" do
        click_on "Topics"
        check "Transport"
      end
      within "[data-process-groups-filter]" do
        click_on "Active (1)"
      end
      within "[data-process-groups-filter]" do
        expect(page).to have_no_content("Test Active Process")
        expect(page).to have_no_content("Test Past Process")
      end
    end

    it "combines upcoming status with taxonomy filter" do
      visit_group_page
      within "[data-process-groups-filter]" do
        click_on "Upcoming (1)"
      end
      within "[data-process-groups-filter]" do
        expect(page).to have_content("Test Upcoming Process")
        click_on "Topics"
        check "Environment"
      end
      within "[data-process-groups-filter]" do
        expect(page).to have_no_content("Test Upcoming Process")
      end
    end

    context "with multiple taxonomy groups" do
      let(:root_area) { create(:taxonomy, organization:, name: { en: "Area" }) }
      let(:child_area) { create(:taxonomy, organization:, parent: root_area, name: { en: "District A" }) }
      let(:area_filter) { create(:taxonomy_filter, root_taxonomy: root_area) }
      let!(:area_filter_item) { create(:taxonomy_filter_item, taxonomy_filter: area_filter, taxonomy_item: child_area) }
      let!(:area_taxonomization) { create(:taxonomization, taxonomy: child_area, taxonomizable: active_process) }

      it "renders both taxonomy group dropdowns" do
        visit_group_page
        within "[data-process-groups-filter]" do
          expect(page).to have_content("Topics")
          expect(page).to have_content("Area")
        end
      end

      it "closes one dropdown when opening another" do
        visit_group_page
        within "[data-process-groups-filter]" do
          click_on "Topics"
          expect(page).to have_content("Environment")

          click_on "Area"
          expect(page).to have_content("District A")
        end
      end

      it "applies AND between taxonomy groups" do
        visit_group_page
        within "[data-process-groups-filter]" do
          click_on "Topics"
          check "Transport"
        end
        within "[data-process-groups-filter]" do
          expect(page).to have_content("Test Past Process")
          click_on "Area"
          check "District A"
        end
        within "[data-process-groups-filter]" do
          expect(page).to have_no_content("Test Past Process")
          expect(page).to have_no_content("Test Active Process")
        end
      end
    end
  end

  context "when taxonomy items have no processes in the group" do
    let(:root_taxonomy) { create(:taxonomy, organization:, name: { en: "Topics" }) }
    let(:child_used) { create(:taxonomy, organization:, parent: root_taxonomy, name: { en: "Environment" }) }
    let(:child_unused) { create(:taxonomy, organization:, parent: root_taxonomy, name: { en: "Unused Topic" }) }
    let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
    let!(:filter_item_used) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_used) }
    let!(:filter_item_unused) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_unused) }
    let!(:taxonomization) { create(:taxonomization, taxonomy: child_used, taxonomizable: active_process) }

    it "shows only taxonomy items used by processes and hides unused ones" do
      visit_group_page
      within "[data-process-groups-filter]" do
        click_on "Topics"
        expect(page).to have_content("Environment")
        expect(page).to have_no_content("Unused Topic")
      end
    end
  end

  context "when no process uses any taxonomy from a root group" do
    let(:root_used) { create(:taxonomy, organization:, name: { en: "Topics" }) }
    let(:root_unused) { create(:taxonomy, organization:, name: { en: "Empty Category" }) }
    let(:child_used) { create(:taxonomy, organization:, parent: root_used, name: { en: "Environment" }) }
    let(:child_unused) { create(:taxonomy, organization:, parent: root_unused, name: { en: "Orphan Item" }) }
    let(:filter_used) { create(:taxonomy_filter, root_taxonomy: root_used) }
    let(:filter_unused) { create(:taxonomy_filter, root_taxonomy: root_unused) }
    let!(:fi_used) { create(:taxonomy_filter_item, taxonomy_filter: filter_used, taxonomy_item: child_used) }
    let!(:fi_unused) { create(:taxonomy_filter_item, taxonomy_filter: filter_unused, taxonomy_item: child_unused) }
    let!(:taxonomization) { create(:taxonomization, taxonomy: child_used, taxonomizable: active_process) }

    it "hides the entire taxonomy group dropdown" do
      visit_group_page
      within "[data-process-groups-filter]" do
        expect(page).to have_content("Topics")
        expect(page).to have_no_content("Empty Category")
      end
    end
  end

  context "when a custom title is set" do
    let!(:content_block) { create(:content_block, organization:, manifest_name: :awesome_process_groups, scope_name: :participatory_process_group_homepage, scoped_resource_id: process_group.id, settings: { "title" => { "en" => "Our Group Processes" } }) }

    it "renders the custom title" do
      visit_group_page
      within "[data-process-groups-filter]" do
        expect(page).to have_content("Our Group Processes")
        expect(page).to have_no_content("Participatory processes")
      end
    end
  end

  context "when there are no grouped processes" do
    let!(:active_process) { nil }
    let!(:past_process) { nil }
    let!(:upcoming_process) { nil }

    it "does not render the content block" do
      visit_group_page
      expect(page).to have_no_content("Participatory processes")
    end
  end

  context "when pagination is needed" do
    let!(:content_block) { create(:content_block, organization:, manifest_name: :awesome_process_groups, scope_name: :participatory_process_group_homepage, scoped_resource_id: process_group.id, settings: { "max_count" => 2 }) }

    it "shows pagination when items exceed max_count" do
      visit_group_page
      within "[data-process-groups-filter]" do
        expect(page).to have_css("[data-pages] a", exact_text: "2")
      end
    end

    it "navigates to another page by clicking its number" do
      visit_group_page
      within "[data-process-groups-filter]" do
        find("[data-pages] a", exact_text: "2").click
      end
      expect(page).to have_current_path(/page=2/)
      within "[data-process-groups-filter]" do
        expect(page).to have_css("[data-pages] a", exact_text: "1")
      end
    end

    it "hides pagination when filter reduces items below max_count" do
      visit_group_page
      within "[data-process-groups-filter]" do
        expect(page).to have_css("[data-pages] a", exact_text: "2")
        click_on "Active (1)"
      end
      within "[data-process-groups-filter]" do
        expect(page).to have_no_css("[data-pages] a", exact_text: "2")
      end
    end
  end
end
