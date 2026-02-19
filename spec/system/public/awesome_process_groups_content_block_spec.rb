# frozen_string_literal: true

require "spec_helper"

describe "Awesome Process Groups content block on homepage" do
  let(:organization) { create(:organization) }
  let!(:content_block) { create(:content_block, organization:, manifest_name: :awesome_process_groups, scope_name: :homepage) }
  let(:process_group) { create(:participatory_process_group, organization:) }

  let!(:active_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Test Active Process" }, start_date: 1.month.ago, end_date: 1.month.from_now) }
  let!(:past_process) { create(:participatory_process, :published, organization:, participatory_process_group: process_group, title: { en: "Test Past Process" }, start_date: 3.months.ago, end_date: 1.month.ago) }

  before do
    switch_to_host(organization.host)
  end

  def visit_homepage
    visit decidim.root_path
  end

  it "renders the content block with default title" do
    visit_homepage
    within "#awesome-process-groups" do
      expect(page).to have_content("Process Groups Extended")
    end
  end

  it "renders both process cards" do
    visit_homepage
    within "#awesome-process-groups" do
      expect(page).to have_content("Test Active Process")
      expect(page).to have_content("Test Past Process")
    end
  end

  it "renders the status label and filter tabs" do
    visit_homepage
    within "#awesome-process-groups" do
      expect(page).to have_content("Status:")
      expect(page).to have_content("Active")
      expect(page).to have_content("Past")
      expect(page).to have_content("All")
    end
  end

  context "when filtering by status" do
    it "shows only active processes when clicking Active" do
      visit_homepage
      within "#awesome-process-groups" do
        click_on "Active (1)"
        expect(page).to have_content("Test Active Process")
        expect(page).to have_no_content("Test Past Process")
      end
    end

    it "shows only past processes when clicking Past" do
      visit_homepage
      within "#awesome-process-groups" do
        click_on "Past (1)"
        expect(page).to have_content("Test Past Process")
        expect(page).to have_no_content("Test Active Process")
      end
    end

    it "shows all processes when clicking All" do
      visit_homepage
      within "#awesome-process-groups" do
        click_on "Active (1)"
        expect(page).to have_no_content("Test Past Process")
        click_on "All (2)"
        expect(page).to have_content("Test Active Process")
        expect(page).to have_content("Test Past Process")
      end
    end
  end

  context "when no taxonomy filters exist" do
    it "does not render the filter by label" do
      visit_homepage
      within "#awesome-process-groups" do
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
      visit_homepage
      within "#awesome-process-groups" do
        expect(page).to have_content("Filter by:")
        expect(page).to have_content("Topics")
      end
    end

    it "opens the dropdown and shows taxonomy items when clicking the trigger" do
      visit_homepage
      within "#awesome-process-groups" do
        click_on "Topics"
        expect(page).to have_content("Environment")
        expect(page).to have_content("Transport")
      end
    end

    it "filters processes by taxonomy when checking a checkbox" do
      visit_homepage
      within "#awesome-process-groups" do
        click_on "Topics"
        check "Environment"
        expect(page).to have_content("Test Active Process")
        expect(page).to have_no_content("Test Past Process")
      end
    end

    it "shows active filter tags when a taxonomy is selected" do
      visit_homepage
      within "#awesome-process-groups" do
        click_on "Topics"
        check "Environment"
        expect(page).to have_css("[data-active-taxonomy-tags]", text: "Environment")
      end
    end

    it "removes filter tag and restores processes when clicking the remove button" do
      visit_homepage
      within "#awesome-process-groups" do
        click_on "Topics"
        check "Environment"
        expect(page).to have_no_content("Test Past Process")

        # Close the open dropdown so it does not intercept the remove-tag click.
        find(".pg-taxonomy-bar .pg-filter-label", match: :first).click
        find("[data-remove-tag]").click
        expect(page).to have_content("Test Active Process")
        expect(page).to have_content("Test Past Process")
      end
    end

    it "combines status and taxonomy filters" do
      visit_homepage
      within "#awesome-process-groups" do
        click_on "Topics"
        check "Transport"
        expect(page).to have_content("Test Past Process")
        expect(page).to have_no_content("Test Active Process")

        click_on "Active (1)"
        expect(page).to have_no_content("Test Past Process")
        expect(page).to have_no_content("Test Active Process")

        click_on "All (2)"
        expect(page).to have_content("Test Past Process")
        expect(page).to have_no_content("Test Active Process")
      end
    end

    it "allows selecting multiple taxonomy items" do
      visit_homepage
      within "#awesome-process-groups" do
        click_on "Topics"
        check "Environment"
        check "Transport"
        expect(page).to have_content("Test Active Process")
        expect(page).to have_content("Test Past Process")
      end
    end

    context "with multiple taxonomy groups" do
      let(:root_scope) { create(:taxonomy, organization:, name: { en: "Scope" }) }
      let(:child_urban) { create(:taxonomy, organization:, parent: root_scope, name: { en: "Urban" }) }
      let(:scope_filter) { create(:taxonomy_filter, root_taxonomy: root_scope) }
      let!(:scope_filter_item) { create(:taxonomy_filter_item, taxonomy_filter: scope_filter, taxonomy_item: child_urban) }
      let!(:scope_taxonomization) { create(:taxonomization, taxonomy: child_urban, taxonomizable: active_process) }

      it "renders both taxonomy group dropdowns" do
        visit_homepage
        within "#awesome-process-groups" do
          expect(page).to have_content("Topics")
          expect(page).to have_content("Scope")
        end
      end

      it "closes one dropdown when opening another" do
        visit_homepage
        within "#awesome-process-groups" do
          click_on "Topics"
          expect(page).to have_content("Environment")

          click_on "Scope"
          expect(page).to have_content("Urban")
        end
      end
    end
  end

  context "when a custom title is set" do
    let!(:content_block) { create(:content_block, organization:, manifest_name: :awesome_process_groups, scope_name: :homepage, settings: { "title" => { "en" => "Our Group Processes" } }) }

    it "renders the custom title" do
      visit_homepage
      within "#awesome-process-groups" do
        expect(page).to have_content("Our Group Processes")
        expect(page).to have_no_content("Process Groups Extended")
      end
    end
  end

  context "when there are no grouped processes" do
    let!(:active_process) { nil }
    let!(:past_process) { nil }

    it "does not render the content block" do
      visit_homepage
      expect(page).to have_no_css("#awesome-process-groups")
    end
  end
end
