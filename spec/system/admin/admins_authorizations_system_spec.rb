# frozen_string_literal: true

require "spec_helper"

describe "System admin manages awesome verifications" do
  let(:admin) { create(:admin) }
  let(:last_awesome_config) { Decidim::DecidimAwesome::AwesomeConfig.last }
  let(:default_locale) { Decidim.available_locales.first }

  before do
    login_as admin, scope: :admin
    visit decidim_system.root_path
  end

  it "creates a new organization" do
    fill_in "Name", with: "Citizen Corp"
    fill_in "Host", with: "www.example.org"
    fill_in "Secondary hosts", with: "foo.example.org\n\rbar.example.org"
    fill_in "Reference prefix", with: "CCORP"
    fill_in "Organization admin name", with: "City Mayor"
    fill_in "Organization admin email", with: "mayor@example.org"
    check "organization_available_locales_en"
    choose "organization_default_locale_en"
    choose "Allow participants to create an account and log in"
    check "Example authorization (Direct)"
    click_on "Show advanced settings"
    within ".awesome_available_authorizations" do
      check "Example authorization (Direct)"
    end
    click_on "Create organization & invite admin"

    within ".flash__message" do
      expect(page).to have_content("Organization successfully created.")
      expect(page).to have_content("mayor@example.org")
    end
    expect(page).to have_content("Citizen Corp")
    expect(last_awesome_config.value).to eq(["dummy_authorization_handler"])
    expect(last_awesome_config.var).to eq("admins_available_authorizations")
    expect(last_awesome_config.organization.name[default_locale]).to eq("Citizen Corp")
    expect(last_awesome_config.organization.host).to eq("www.example.org")
  end

  context "when organization exists" do
    let!(:organization) { create(:organization) }

    before do
      visit decidim_system.edit_organization_path(organization)
    end

    it "updates an organization" do
      new_name = {
        en: "Citizen Corp",
        es: "Corporación Ciudadana",
        ca: "Corporació Ciutadana"
      }
      fill_in_i18n(
        :update_organization_name,
        "#update_organization-name-tabs",
        new_name
      )
      check "Example authorization (Direct)"
      click_on "Show advanced settings"
      within ".awesome_available_authorizations" do
        check "Example authorization (Direct)"
      end
      click_on "Save"

      within ".flash__message" do
        expect(page).to have_content("Organization successfully updated.")
      end
      expect(page).to have_content("Citizen Corp")
      expect(last_awesome_config.value).to eq(["dummy_authorization_handler"])
      expect(last_awesome_config.var).to eq("admins_available_authorizations")
      expect(last_awesome_config.organization.name).to eq("ca" => "Corporació Ciutadana", "en" => "Citizen Corp", "es" => "Corporación Ciudadana")
      expect(last_awesome_config.organization.host).to eq(organization.host)
    end
  end

  context "when admins_available_authorizations is disabled" do
    let!(:organization) { create(:organization) }

    before do
      allow(Decidim::DecidimAwesome.config).to receive(:admins_available_authorizations).and_return(:disabled)
      visit decidim_system.edit_organization_path(organization)
    end

    it "does not show the awesome configuration" do
      click_on "Show advanced settings"

      expect(page).to have_no_content("Decidim Awesome Tweaks")
      expect(page).to have_no_content("Allow admins to manually verify users with these authorizations")
    end
  end
end
