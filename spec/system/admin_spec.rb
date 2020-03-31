# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/config_examples"

describe "Visit the admin page", type: :system do
  let(:organization) { create :organization }
  let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.root_path
  end

  context "when manages tweaks" do
    before do
      click_link "Decidim awesome"
    end

    it "renders the admin page" do
      expect(page).to have_content("Decidim Awesome")
    end
  end

  include_examples "javascript config vars"
end
