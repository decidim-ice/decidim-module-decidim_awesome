# frozen_string_literal: true

require "spec_helper"

describe "Edit proposal after import", type: :system do
  let!(:organization) { create(:organization) }
  let(:manifest_name) { "proposals" }
  let(:participatory_space) { create(:participatory_process, organization: organization) }
  let!(:component) { create(:proposal_component, organization: organization, participatory_space: participatory_space) }
  let!(:original_component) { create(:proposal_component, organization: organization, participatory_space: participatory_space) }
  let!(:proposals) { create_list(:proposal, 3, :accepted, component: component) }
  let(:user) { create :user, organization: organization }
  let!(:allow_to_edit_proposals_after_import) { create(:awesome_config, organization: organization, var: :allow_to_edit_proposals_after_import, value: config_value) }

  include_context "when managing a component as an admin"

  before do
    page.find("a", text: original_component.name["en"]).click
    page.find(".imports").click
    click_link "Import proposals from another component"

    within ".import_proposals" do
      select component.name["en"], from: "Origin component"
      check "Accepted"
      check "Keep original authors"
      check "Import proposals"
    end

    click_button "Import proposals"
  end

  context "when config is set to true" do
    let(:config_value) { true }

    it "allows the user to edit all 3 imported proposals" do
      page.find("a", text: component.name["en"]).click

      proposals.each do |proposal|
        expect(page).to have_content(proposal.title["en"])
      end

      expect(page).to have_css('a[title="Edit proposal"]', count: 3)
      expect(Decidim::Proposals::Proposal.count).to eq(6)
    end
  end

  context "when config is set to false" do
    let(:config_value) { false }

    it "allows the user to edit all 3 imported proposals" do
      page.find("a", text: component.name["en"]).click

      proposals.each do |proposal|
        expect(page).to have_content(proposal.title["en"])
      end

      expect(page).not_to have_css('a[title="Edit proposal"]')
    end
  end
end
