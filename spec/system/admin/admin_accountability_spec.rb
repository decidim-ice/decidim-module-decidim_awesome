# frozen_string_literal: true

require "spec_helper"

describe "Admin accountability", type: :system do
  let(:organization) { create :organization }
  let!(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:status) { true }

  before do
    allow(Decidim::DecidimAwesome.config).to receive(:allow_admin_accountability).and_return(status)
    switch_to_host(organization.host)
    login_as user, scope: :user

    visit decidim_admin.root_path
  end

  context "when admin accountability is enabled" do
    it "shows the admin accountability link" do
      click_link "Participants"

      expect(page).to have_content("Admin accountability")
    end
  end

  context "when admin accountability is disabled" do
    let(:status) { :disabled }

    it "does not show the admin accountability link" do
      click_link "Participants"

      expect(page).not_to have_content("Admin accountability")
    end
  end
end
