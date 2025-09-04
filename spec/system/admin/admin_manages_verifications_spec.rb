# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/box_label_editor_examples"

describe "Admin manages verification tweaks" do
  let(:organization) { create(:organization, available_authorizations: [:dummy_authorization_handler, :another_dummy_authorization_handler, :id_documents]) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:last_force_authorizations) { Decidim::DecidimAwesome::AwesomeConfig.find_by(var: :force_authorizations) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  it "saves the configuration" do
    visit decidim_admin_decidim_awesome.config_path(:verifications)
    click_on "Add a new authorization group"
    check "Example authorization (Direct)"

    page.execute_script <<~SCRIPT
      document.querySelector(".force_authorization_container .editor-container .ProseMirror:first-child").innerHTML = "<p>Help text <strong>with HTML</strong></p>"
      document.querySelector(".force_authorization_container input[name*=force_authorization_help_text_en]:first-child").value = "<p>Help text <strong>with HTML</strong></p>"
    SCRIPT

    click_on "Update configuration"

    expect(page).to have_content("updated successfully")
    expect(last_force_authorizations.reload.value.values.first).to eq(
      {
        "authorization_handlers" => {
          "dummy_authorization_handler" => {
            "options" => { "allowed_postal_codes" => "08001" }
          }
        },
        "force_authorization_help_text" => { "ca" => "", "en" => "<p>Help text <strong>with HTML</strong></p>", "es" => "" }
      }
    )
  end

  context "when a configuration exists" do
    let(:organization) { create(:organization, available_authorizations: [:dummy_authorization_handler, :another_dummy_authorization_handler]) }
    let!(:force_authorizations) do
      create(:awesome_config, organization:, var: :force_authorizations, value: {
               "foo" => {
                 "authorization_handlers" => {
                   "dummy_authorization_handler" => {},
                   "another_dummy_authorization_handler" => {}
                 }
               }
             })
    end

    before do
      visit decidim_admin_decidim_awesome.config_path(:verifications)
    end

    it_behaves_like "edits box label inline", :verifications, :foo

    it "allows to unselect existing workflows" do
      uncheck "Another example authorization (Direct)"

      click_on "Update configuration"

      expect(page).to have_content("updated successfully")
      expect(last_force_authorizations.reload.value).to eq("foo" => { "authorization_handlers" => { "dummy_authorization_handler" => { "options" => { "allowed_postal_codes" => "08001"} } }, "force_authorization_help_text" => { "ca" => "", "en" => "", "es" => "" } })
    end
  end
end
