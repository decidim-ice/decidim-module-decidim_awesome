# frozen_string_literal: true

require "spec_helper"

describe "Admin manages verification tweaks" do
  let(:organization) { create(:organization, available_authorizations: [:dummy_authorization_handler, :another_dummy_authorization_handler, :id_documents]) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:last_authorization_groups) { Decidim::DecidimAwesome::AwesomeConfig.find_by(var: :authorization_groups) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  it "saves the configuration" do
    visit decidim_admin_decidim_awesome.config_path(:verifications)
    click_on "Add a new permissions group"
    check "Example authorization (Direct)"

    check "Allow access if any of the authorizations is granted (by default, all are required)"

    page.execute_script <<~SCRIPT
      document.querySelector(".authorization_group_container .editor-container .ProseMirror:first-child").innerHTML = "<p>Help text <strong>with HTML</strong></p>"
      document.querySelector(".authorization_group_container input[name*=force_authorization_help_text_en]:first-child").value = "<p>Help text <strong>with HTML</strong></p>"
    SCRIPT

    click_on "Update configuration"

    expect(page).to have_content("updated successfully")
    expect(last_authorization_groups.reload.value.values.first).to eq(
      {
        "authorization_handlers" => {
          "dummy_authorization_handler" => {
            "options" => { "allowed_postal_codes" => "08001", "allowed_scope_id" => "" }
          }
        },
        "force_authorization_help_text" => { "ca" => "", "en" => "<p>Help text <strong>with HTML</strong></p>", "es" => "" },
        "force_authorization_with_any_method" => true
      }
    )
  end

  context "when a configuration exists" do
    let(:organization) { create(:organization, available_authorizations: [:dummy_authorization_handler, :another_dummy_authorization_handler]) }
    let!(:authorization_groups) do
      create(:awesome_config, organization:, var: :authorization_groups, value: {
               "some-id" => {
                 "authorization_handlers" => {
                   "dummy_authorization_handler" => {},
                   "another_dummy_authorization_handler" => {}
                 }
               }
             })
    end

    it "allows to unselect existing workflows" do
      visit decidim_admin_decidim_awesome.config_path(:verifications)
      uncheck "Another example authorization (Direct)"

      click_on "Update configuration"

      expect(page).to have_content("updated successfully")
      expect(last_authorization_groups.reload.value).to eq("some-id" => { "authorization_handlers" => { "dummy_authorization_handler" => { "options" => { "allowed_postal_codes" => "08001", "allowed_scope_id" => "" } } }, "force_authorization_help_text" => { "ca" => "", "en" => "", "es" => "" }, "force_authorization_with_any_method" => true })
    end
  end
end
