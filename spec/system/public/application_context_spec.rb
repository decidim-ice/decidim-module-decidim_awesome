# frozen_string_literal: true

require "spec_helper"

describe "Application Context Configuration" do
  let(:organization) { create(:organization) }
  let!(:participatory_process) { create(:participatory_process, organization:) }
  let!(:user) { create(:user, :confirmed, organization:) }

  describe "application context setting" do
    let(:config) { Decidim::DecidimAwesome::Config.new(organization) }

    context "when user is anonymous" do
      it "sets context as anonymous" do
        config.application_context!
        expect(config.context[:context]).to eq("anonymous")
      end

      it "sets context as anonymous with nil user" do
        config.application_context!(current_user: nil)
        expect(config.context[:context]).to eq("anonymous")
      end
    end

    context "when user is logged in" do
      it "sets context as user_logged_in" do
        config.application_context!(current_user: user)
        expect(config.context[:context]).to eq("user_logged_in")
      end
    end
  end

  describe "menu visibility with application context" do
    let!(:config) { create(:awesome_config, organization:, var: :menu, value: menu) }
    let(:menu) { [logged_only_item, non_logged_item] }
    let(:logged_only_item) do
      {
        url: "/logged-content",
        label: {
          "en" => "Members Only"
        },
        position: 5,
        visibility: "logged"
      }
    end
    let(:non_logged_item) do
      {
        url: "/public-content", 
        label: {
          "en" => "Public Content"
        },
        position: 6,
        visibility: "non_logged"
      }
    end

    before do
      switch_to_host(organization.host)
    end

    context "when user is anonymous" do
      before do
        visit decidim_participatory_processes.participatory_processes_path
        find_by_id("main-dropdown-summary").hover
      end

      it "shows non_logged items and hides logged items" do
        within "#main-dropdown-menu" do
          expect(page).to have_content("Public Content")
          expect(page).to have_no_content("Members Only")
        end
      end
    end

    context "when user is logged in" do
      before do
        login_as user, scope: :user
        visit decidim_participatory_processes.participatory_processes_path
        find_by_id("main-dropdown-summary").hover
      end

      it "shows logged items and hides non_logged items" do
        within "#main-dropdown-menu" do
          expect(page).to have_content("Members Only")
          expect(page).to have_no_content("Public Content")
        end
      end
    end
  end

  describe "application context in different controllers" do
    let!(:config) { create(:awesome_config, organization:, var: :force_authorization, value: force_auth_config) }
    let(:force_auth_config) do
      [{
        "authorization_handlers" => ["dummy_authorization_handler"],
        "force_authorization_help_text" => { "en" => "Verification required" }
      }]
    end

    context "when accessing required authorizations" do
      before do
        allow(Decidim::DecidimAwesome.config).to receive(:force_authorizations).and_return(true)
        switch_to_host(organization.host)
      end

      context "with anonymous user" do
        it "sets anonymous context in authorization flow" do
          visit decidim_decidim_awesome.required_authorizations_path
          expect(page).to have_current_path(decidim_decidim_awesome.required_authorizations_path)
          # The page should load without errors, indicating context was set properly
          expect(page).to have_content("Authorization")
        end
      end

      context "with logged user" do
        before do
          login_as user, scope: :user
        end

        it "sets logged user context in authorization flow" do
          visit decidim_decidim_awesome.required_authorizations_path
          expect(page).to have_current_path(decidim_decidim_awesome.required_authorizations_path)
          # The page should load without errors, indicating context was set properly
          expect(page).to have_content("Authorization")
        end
      end
    end
  end

  describe "context preservation across requests" do
    let!(:config) { create(:awesome_config, organization:, var: :menu, value: menu) }
    let(:menu) do
      [{
        url: "/user-dashboard",
        label: {
          "en" => "My Dashboard"
        },
        position: 1,
        visibility: "logged"
      }]
    end

    context "when user logs in and navigates" do
      before do
        switch_to_host(organization.host)
        visit decidim_participatory_processes.participatory_processes_path
        find_by_id("main-dropdown-summary").hover
      end

      it "updates menu visibility after login" do
        # Initially anonymous - should not see logged menu
        within "#main-dropdown-menu" do
          expect(page).to have_no_content("My Dashboard")
        end

        # Log in
        click_link "Log in"
        fill_in "session_email", with: user.email
        fill_in "session_password", with: "decidim123456789"
        click_button "Log in"

        # Navigate and check menu again
        visit decidim_participatory_processes.participatory_processes_path
        find_by_id("main-dropdown-summary").hover

        # Should now see logged menu
        within "#main-dropdown-menu" do
          expect(page).to have_content("My Dashboard")
        end
      end
    end
  end
end