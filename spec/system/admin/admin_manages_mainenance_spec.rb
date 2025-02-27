# frozen_string_literal: true

require "spec_helper"

describe "Admin manages maintenance" do
  let(:user) { create(:user, :confirmed, :admin, organization:) }
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, title: { "en" => "A process" }, organization:) }
  let!(:component) { create(:proposal_component, name: { "en" => "Erasable" }, participatory_space:) }
  let!(:another_component) { create(:proposal_component, name: { "en" => "Has mixed data" }, participatory_space:) }
  let!(:modern_component) { create(:proposal_component, name: { "en" => "Has modern data" }, participatory_space:) }
  let!(:missing_component) { create(:proposal_component, name: { "en" => "Missing data" }, participatory_space:) }
  let!(:proposal) { create(:proposal, component:) }
  let!(:proposal2) { create(:proposal, component:) }
  let!(:another_proposal) { create(:proposal, component: another_component) }
  let!(:modern_proposal) { create(:proposal, component: another_component) }
  let!(:modern_proposal2) { create(:proposal, component: modern_component) }
  let!(:missing_proposal) { create(:proposal, component: missing_component) }
  let!(:extra_fields) { create(:awesome_proposal_extra_fields, private_body: "private", proposal:) }
  let!(:extra_fields2) { create(:awesome_proposal_extra_fields, private_body: "private", proposal: proposal2) }
  let!(:modern_extra_fields) { create(:awesome_proposal_extra_fields, private_body: "private", proposal: modern_proposal) }
  let!(:modern_extra_fields2) { create(:awesome_proposal_extra_fields, private_body: "private", proposal: modern_proposal2) }
  let!(:another_extra_fields) { create(:awesome_proposal_extra_fields, private_body: "private", proposal: another_proposal) }
  let(:params) do
    { id: }
  end
  let(:id) { "private_data" }
  let(:time_ago) { 4.months.ago }

  before do
    # rubocop:disable Rails/SkipsModelValidations
    extra_fields.update_column(:private_body_updated_at, time_ago)
    extra_fields2.update_column(:private_body_updated_at, time_ago)
    modern_extra_fields.update_column(:private_body_updated_at, 2.months.ago)
    modern_extra_fields2.update_column(:private_body_updated_at, 2.months.ago)
    another_extra_fields.update_column(:private_body_updated_at, time_ago)
    # rubocop:enable Rails/SkipsModelValidations
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when visiting the maintenance page" do
    before do
      visit decidim_admin_decidim_awesome.maintenance_path(:private_data)
    end

    it "shows the private data maintenance page" do
      within ".table-list thead" do
        expect(page).to have_content("Space / Component")
        expect(page).to have_content("Total affected")
        expect(page).to have_content("Last update")
        expect(page).to have_content("Actions")
      end
    end

    it "show to private data information" do
      within ".table-list tbody" do
        expect(page).to have_content(translated(component.name))
        expect(page).to have_content(translated(another_component.name))
        expect(page).to have_content(translated(modern_component.name))
        expect(page).to have_no_content(translated(missing_component.name))
        expect(page).to have_content("Delete all")
        expect(page).to have_content("4 months ago")
        expect(page).to have_content("2 months ago", count: 2)
        expect(page).to have_no_content("Done")
        expect(page).to have_css("span", class: "not-destroyable", count: 2)
      end
    end

    it "allows to delete all private data for a component" do
      within ".table-list tbody tr[data-id=\"#{component.id}\"]" do
        expect(page).to have_content(translated(component.name))
        expect(page).to have_content("4 months ago")
        expect(page).to have_no_content("Done")
        expect(page).to have_content("Delete all")
        expect(page).to have_no_css("span", class: "not-destroyable")
      end

      within ".table-list tbody tr[data-id=\"#{another_component.id}\"]" do
        expect(page).to have_content(translated(another_component.name))
        expect(page).to have_content("2 months ago")
        expect(page).to have_no_content("Done")
        expect(page).to have_no_content("Delete all")
        expect(page).to have_css("span", class: "not-destroyable")
      end

      within ".table-list tbody tr[data-id=\"#{modern_component.id}\"]" do
        expect(page).to have_content(translated(modern_component.name))
        expect(page).to have_content("2 months ago")
        expect(page).to have_no_content("Done")
        expect(page).to have_no_content("Delete all")
        expect(page).to have_css("span", class: "not-destroyable")
      end

      accept_confirm do
        click_on "Delete all"
      end

      expect(page).to have_content("Private data for A process / Erasable is set to be destroyed.")
      expect(page).to have_no_content("Delete all")
      expect(page).to have_no_content("Done")
      expect(page).to have_css(".loading-spinner")

      Decidim::DecidimAwesome::DestroyPrivateDataJob.perform_now(component)

      expect(page).to have_content("Done")
    end

    it "deletes all private data" do
      perform_enqueued_jobs do
        accept_confirm do
          click_on "Delete all"
        end
        within ".table-list tbody" do
          expect(page).to have_no_content("Delete all")
          expect(page).to have_no_content(translated(component.name))
        end
      end
    end
  end
end
