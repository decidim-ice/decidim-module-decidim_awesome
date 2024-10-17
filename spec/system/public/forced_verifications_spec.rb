# frozen_string_literal: true

require "spec_helper"

describe "Forced verifications" do
  let(:organization) { create(:organization, available_authorizations: [:dummy_authorization_handler, :another_dummy_authorization_handler]) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let(:restricted_path) { "/" }
  let!(:force_authorization_after_login) { create(:awesome_config, organization:, var: :force_authorization_after_login, value: %w(dummy_authorization_handler another_dummy_authorization_handler)) }
  let!(:force_authorization_with_any_method) { create(:awesome_config, organization:, var: :force_authorization_with_any_method, value: any_method) }
  let!(:force_authorization_help_text) { create(:awesome_config, organization:, var: :force_authorization_help_text, value: { en: "Help text <strong>with HTML</strong>" }) }
  let(:any_method) { false }

  context "when the user is not logged in" do
    before do
      switch_to_host(organization.host)
      visit restricted_path
    end

    it "page can be visited" do
      expect(page).to have_current_path(restricted_path, ignore_query: true)
    end
  end

  context "when the user is logged in" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit restricted_path
    end

    it "user is redirected to the required authorizations page" do
      expect(page).to have_current_path(decidim_decidim_awesome.required_authorizations_path(redirect_url: restricted_path))
      expect(page).to have_content("you need to authorize your account with a valid authorization")
      expect(page).to have_content("lease verify yourself with all these methods before being able to access the platform")
      expect(page).to have_content("Verify against the example authorization handler")
      expect(page).to have_content("Verify against another example of authorization handler")
      expect(page).to have_content("Help text with HTML")
      expect(page).to have_link("let me logout", href: "/users/sign_out")

      click_link "Verify against the example authorization handler"

      fill_in "Document number", with: "12345678X"
      click_on "Send"
      expect(page).not_to have_content("Verify against the example authorization handler")
      click_link "Verify against another example of authorization handler"
      fill_in "Passport number", with: "A12345678"
      click_on "Send"
      expect(page).to have_current_path(restricted_path, ignore_query: true)
    end

    it "user can logout" do
      click_link "let me logout"
      expect(page).to have_current_path("/")
    end

    it "can visit allowed controllers" do
      visit "/authorizations"
      expect(page).to have_current_path("/authorizations")

      visit "/account"
      expect(page).to have_current_path("/account")

      visit "/pages"
      expect(page).to have_current_path("/pages")
    end

    context "when any method is allowed" do
      let(:any_method) { true }

      it "user is redirected to the required authorizations page" do
        click_link "Verify against the example authorization handler"

        fill_in "Document number", with: "12345678X"
        click_on "Send"
        expect(page).to have_current_path(restricted_path, ignore_query: true)
      end
    end

    context "when is an admin" do
      let(:user) { create(:user, :confirmed, :admin, organization:) }
      let(:restricted_path) { "/admin" }

      it "can visit restricted path" do
        expect(page).to have_current_path(restricted_path, ignore_query: true)
      end
    end

    context "when user is not confirmed" do
      let(:user) { create(:user, organization:) }

      it "is redirected as normal" do
        expect(page).to have_current_path("/users/sign_in")
      end
    end
  end
end
