# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/config_examples"

describe "Visit the admin page", type: :system do
  let(:organization) { create :organization, rich_text_editor_in_public_views: rte_enabled }
  let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }
  let(:rte_enabled) { true }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.root_path
    click_link "Decidim awesome"
  end

  include_examples "javascript config vars"

  context "when manages tweaks" do
    it "renders the admin page" do
      expect(page).to have_content("Decidim Awesome")
    end
  end

  context "when visiting system compatibility" do
    before do
      click_link "System compatibility"
    end

    it "renders the page" do
      expect(page).to have_content("System compatibility checks")
      expect(page).not_to have_xpath("//span[@class='text-alert']")
      expect(page).to have_xpath("//span[@class='text-success']")
    end
  end

  context "when visiting editor hacks" do
    before do
      click_link "Editor hacks"
    end

    it "renders the page" do
      expect(page).to have_content("Tweaks for editors")
    end
  end

  context "when visiting surveys hacks" do
    before do
      click_link "Surveys & forms"
    end

    it "renders the page" do
      expect(page).to have_content("Tweaks for surveys")
    end
  end

  context "when visiting proposal hacks" do
    before do
      click_link "Proposals hacks"
    end

    context "and rich text editor for participants is enabled" do
      it "renders the page" do
        expect(page).to have_content("Tweaks for proposals")
        expect(page).to have_content("\"Rich text editor for participants\" is enabled")
      end
    end

    context "and rich text editor for participants is disabled" do
      let(:rte_enabled) { false }

      it "renders the page" do
        expect(page).to have_content("Tweaks for proposals")
        expect(page).not_to have_content("\"Rich text editor for participants\" is enabled")
      end
    end
  end
end
