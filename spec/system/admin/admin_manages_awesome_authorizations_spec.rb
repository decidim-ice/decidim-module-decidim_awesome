# frozen_string_literal: true

require "spec_helper"

describe "Admin manages awesome authorizations" do
  let(:organization) { create(:organization, available_authorizations: available_authorizations) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:available_authorizations) { [] }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  context "when awesome_authorization_handler is enabled" do
    before do
      allow(Decidim::DecidimAwesome.config).to receive(:awesome_authorization_handler).and_return(true)
      visit decidim_admin_decidim_awesome.awesome_authorizations_path
    end

    context "when authorization is available in organization" do
      let(:available_authorizations) { ["awesome_authorization_handler"] }

      it "does not show the not available callout" do
        expect(page).to have_no_selector(".callout.alert")
      end

      it "shows the page title" do
        expect(page).to have_content("Awesome authorizations")
      end
    end

    context "when authorization is not available in organization" do
      it "shows the not available callout" do
        expect(page).to have_css(".callout.alert")
        expect(page).to have_content("In order to use this feature, you must enable the awesome authorization workflow")
      end

      it "shows a link to system admin" do
        expect(page).to have_link("System admin", href: %r{/system/organizations/.+/edit})
      end
    end
  end

  context "when awesome_authorization_handler is disabled" do
    before do
      allow(Decidim::DecidimAwesome.config).to receive(:awesome_authorization_handler).and_return(false)
    end

    it "shows the page (permission check happens at authorization level)" do
      visit decidim_admin_decidim_awesome.awesome_authorizations_path
      expect(page).to have_current_path(decidim_admin_decidim_awesome.awesome_authorizations_path)
      expect(page).to have_content("Awesome authorizations")
    end
  end
end
