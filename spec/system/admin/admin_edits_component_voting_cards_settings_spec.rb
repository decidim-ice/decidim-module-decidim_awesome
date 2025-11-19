# frozen_string_literal: true

require "spec_helper"

describe "Admin edits component voting cards settings" do
  let(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let!(:component) do
    create(
      :proposal_component,
      participatory_space: participatory_process,
      settings: {
        awesome_voting_manifest: "default"
      }
    )
  end

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_participatory_processes.edit_component_path(participatory_process, component)
  end

  context "when awesome_voting_manifest is default", :slow do
    it "hides voting cards fields" do
      expect(page).to have_select("Support type", selected: "Simple vote (default)")

      # Voting cards fields should not be visible
      expect(page).to have_no_content("Title for the voting box")
      expect(page).to have_no_content("Show instructions/help modal when support is clicked")
      expect(page).to have_no_content("Add an abstention option")
      expect(page).to have_no_content("Support instructions/help")
    end
  end

  context "when changing to voting_cards", :slow do
    it "shows voting cards fields" do
      select "Voting using coloured cards", from: "Support type"

      expect(page).to have_content("Title for the voting box")
      expect(page).to have_content("Show instructions/help modal when support is clicked")
      expect(page).to have_content("Add an abstention option")
      expect(page).to have_content("Support instructions/help")
    end

    it "hides fields when changing back to default" do
      select "Voting using coloured cards", from: "Support type"
      expect(page).to have_content("Title for the voting box")

      select "Simple vote (default)", from: "Support type"

      expect(page).to have_no_content("Title for the voting box")
      expect(page).to have_no_content("Show instructions/help modal when support is clicked")
      expect(page).to have_no_content("Add an abstention option")
      expect(page).to have_no_content("Support instructions/help")
    end
  end
end
