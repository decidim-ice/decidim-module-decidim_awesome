# frozen_string_literal: true

require "spec_helper"

describe "Assembly creation with decidim_awesome constraints" do
  let(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  context "when creating a new assembly" do
    it "does not raise error when accessing assembly creation form" do
      visit decidim_admin_assemblies.new_assembly_path

      expect(page).to have_content("New assembly")

      expect(page).not_to have_content("undefined method")
      expect(page).to have_content("New assembly")
    end
  end
end
