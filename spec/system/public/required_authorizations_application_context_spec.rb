# frozen_string_literal: true

require "spec_helper"

describe "Required Authorizations with Application Context" do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:config) { create(:awesome_config, organization:, var: :force_authorization, value: force_auth_settings) }
  let(:force_auth_settings) do
    [{
      "authorization_handlers" => ["dummy_authorization_handler"],
      "force_authorization_help_text" => { "en" => "You need to verify your identity" }
    }]
  end

  before do
    allow(Decidim::DecidimAwesome.config).to receive(:force_authorizations).and_return(true)
    switch_to_host(organization.host)
  end

  context "when anonymous user accesses required authorizations" do
    it "properly sets anonymous application context" do
      visit decidim_decidim_awesome.required_authorizations_path

      # The controller should handle anonymous context without errors
      expect(page).to have_current_path(decidim_decidim_awesome.required_authorizations_path)
      expect(page).to have_content("Authorization")
      
      # Page should load successfully, indicating application_context! worked correctly
      expect(page).not_to have_selector(".alert.alert-danger")
    end

    it "handles redirect URL context extraction for anonymous users" do
      participatory_process = create(:participatory_process, organization:)
      redirect_url = decidim_participatory_processes.participatory_process_path(participatory_process.slug)
      
      visit decidim_decidim_awesome.required_authorizations_path(redirect_url:)

      # Should set context from redirect URL and application context as anonymous
      expect(page).to have_current_path(decidim_decidim_awesome.required_authorizations_path)
      expect(page).to have_content("Authorization")
    end
  end

  context "when logged user accesses required authorizations", with_authorization_workflows: ["dummy_authorization_handler"] do
    before do
      login_as user, scope: :user
    end

    it "properly sets logged user application context" do
      visit decidim_decidim_awesome.required_authorizations_path

      # The controller should handle logged user context without errors
      expect(page).to have_current_path(decidim_decidim_awesome.required_authorizations_path)
      expect(page).to have_content("Authorization")
      
      # Page should load successfully, indicating application_context! worked correctly
      expect(page).not_to have_selector(".alert.alert-danger")
    end

    it "handles redirect URL context extraction for logged users" do
      participatory_process = create(:participatory_process, organization:)
      redirect_url = decidim_participatory_processes.participatory_process_path(participatory_process.slug)
      
      visit decidim_decidim_awesome.required_authorizations_path(redirect_url:)

      # Should set context from redirect URL and application context as logged user
      expect(page).to have_current_path(decidim_decidim_awesome.required_authorizations_path)
      expect(page).to have_content("Authorization")
    end

    context "when user is already authorized" do
      let!(:authorization) { create(:authorization, granted_at: Time.zone.now, user:, name: "dummy_authorization_handler") }

      it "redirects back when user context shows they're already authorized" do
        participatory_process = create(:participatory_process, organization:)
        redirect_url = decidim_participatory_processes.participatory_process_path(participatory_process.slug)
        
        visit decidim_decidim_awesome.required_authorizations_path(redirect_url:)

        # Should redirect because application_context! detected authorized user
        expect(page).to have_current_path(redirect_url)
      end
    end
  end

  context "when accessing from different contexts" do
    let!(:participatory_process) { create(:participatory_process, organization:) }
    let!(:component) { create(:proposal_component, participatory_space: participatory_process) }
    
    it "preserves application context across different participatory space contexts" do
      # Test anonymous access from component context
      redirect_url = main_component_path(component)
      visit decidim_decidim_awesome.required_authorizations_path(redirect_url:)
      
      expect(page).to have_current_path(decidim_decidim_awesome.required_authorizations_path)
      expect(page).to have_content("Authorization")

      # Login and test from same component context
      click_link "Log in"
      fill_in "session_email", with: user.email
      fill_in "session_password", with: "decidim123456789"
      click_button "Log in"

      visit decidim_decidim_awesome.required_authorizations_path(redirect_url:)
      
      expect(page).to have_current_path(decidim_decidim_awesome.required_authorizations_path)
      expect(page).to have_content("Authorization")
    end
  end

  context "when application context affects authorization requirements" do
    let(:force_auth_settings) do
      [{
        "authorization_handlers" => ["dummy_authorization_handler"],
        "force_authorization_help_text" => { "en" => "Logged users need verification" }
      }]
    end
    let!(:constraint) { create(:config_constraint, awesome_config: config, settings: { context: "user_logged_in" }) }

    it "only requires authorization for logged users when constrained by context" do
      # Anonymous user should not be required to authorize
      visit decidim_decidim_awesome.required_authorizations_path
      
      # Should either redirect to root or show no authorization required
      expect(page).to have_current_path(decidim.root_path).or have_content("No authorization")

      # Logged user should be required to authorize
      login_as user, scope: :user
      visit decidim_decidim_awesome.required_authorizations_path

      expect(page).to have_current_path(decidim_decidim_awesome.required_authorizations_path)
      expect(page).to have_content("Authorization")
    end
  end
end