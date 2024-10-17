# frozen_string_literal: true

require "spec_helper"

describe "Admin manages verification tweaks" do
  let(:organization) { create(:organization, available_authorizations: [:dummy_authorization_handler, :another_dummy_authorization_handler]) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:last_force_authorization_after_login) { Decidim::DecidimAwesome::AwesomeConfig.find_by(var: :force_authorization_after_login) }
  let(:last_force_authorization_with_any_method) { Decidim::DecidimAwesome::AwesomeConfig.find_by(var: :force_authorization_with_any_method) }
  let(:last_force_authorization_help_text) { Decidim::DecidimAwesome::AwesomeConfig.find_by(var: :force_authorization_help_text) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_decidim_awesome.config_path(:verifications)
  end

  it "saves the configuration" do
    page.execute_script("document.getElementById('config_force_authorization_after_login').tomselect.setValue('dummy_authorization_handler')")

    check "Allow access if any of the authorizations is granted (by default, all are required)"

    fill_in_i18n_editor(:config_force_authorization_help_text,
                        "#config-force_authorization_help_text-tabs",
                        en: "Help text <strong>with HTML</strong>",
                        ca: "Text d'ajuda <strong>amb HTML</strong>",
                        es: "Texto de ayuda <strong>con HTML</strong>")
    click_button "Update configuration"

    expect(page).to have_content("updated successfully")
    expect(last_force_authorization_after_login.reload.value).to eq(["dummy_authorization_handler"])
    expect(last_force_authorization_with_any_method.reload.value).to eq(true)
    expect(last_force_authorization_help_text.reload.value).to eq("en" => "<p>Help text <strong>with HTML</strong></p>", "ca" => "<p>Text d'ajuda <strong>amb HTML</strong></p>", "es" => "<p>Texto de ayuda <strong>con HTML</strong></p>")
  end
end
