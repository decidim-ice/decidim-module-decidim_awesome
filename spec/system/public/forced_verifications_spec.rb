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
      sleep 0.1
      visit restricted_path
    end

    it "user is redirected to the required authorizations page" do
      expect(page).to have_current_path(decidim_decidim_awesome.required_authorizations_path(redirect_url: restricted_path))
      expect(page).to have_content("you need to authorize your account with a valid authorization")
      expect(page).to have_content("lease verify yourself with all these methods before being able to access the platform")
      expect(page).to have_content("Verify with Example authorization")
      expect(page).to have_content("Verify with Another example authorization")
      expect(page).to have_content("Help text with HTML")
      expect(page).to have_link("let me logout")
      expect(page).to have_no_content("GRANTED VERIFICATIONS")
      expect(page).to have_no_content("PENDING VERIFICATIONS")
      expect(page).to have_content("NOT VERIFIED YET")

      click_on "Verify with Example authorization"

      fill_in "Document number", with: "12345678X"
      click_on "Send"
      expect(page).to have_no_content("Verify with Example authorization")
      click_on "Verify with Another example authorization"
      fill_in "Passport number", with: "A12345678"
      click_on "Send"
      expect(page).to have_current_path(restricted_path, ignore_query: true)
    end

    it "user can logout" do
      click_on "let me logout"
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
        click_on "Verify with Example authorization"

        fill_in "Document number", with: "12345678X"
        click_on "Send"
        expect(page).to have_current_path(restricted_path, ignore_query: true)
      end
    end

    context "when is an admin" do
      let(:user) { create(:user, :confirmed, :admin, organization:) }

      it "requrires verification" do
        expect(page).to have_current_path(decidim_decidim_awesome.required_authorizations_path(redirect_url: restricted_path))
      end

      context "and visits the admin" do
        let(:restricted_path) { "/admin" }

        it "can visit an admin path" do
          expect(page).to have_current_path(restricted_path, ignore_query: true)
        end
      end
    end

    context "when there are pending verifications" do
      let(:organization) { create(:organization, available_authorizations: [:dummy_authorization_handler, :id_documents]) }
      let!(:force_authorization_after_login) { create(:awesome_config, organization:, var: :force_authorization_after_login, value: %w(dummy_authorization_handler id_documents)) }

      before do
        create(:authorization, granted_at: nil, user:, name: "id_documents")
        visit restricted_path
      end

      it "user is redirected and shows the pending" do
        expect(page).to have_current_path(decidim_decidim_awesome.required_authorizations_path(redirect_url: restricted_path))
        expect(page).to have_no_content("Verify with Identity documents")
        expect(page).to have_content("Identity documents")
        expect(page).to have_content("Verify with Example authorization")
        expect(page).to have_content("PENDING VERIFICATIONS")
        expect(page).to have_content("NOT VERIFIED YET")
        expect(page).to have_no_content("GRANTED VERIFICATIONS")
      end
    end

    context "when there are granted verifications" do
      before do
        create(:authorization, :granted, user:, name: "dummy_authorization_handler")
        visit restricted_path
      end

      it "user is redirected and shows the granted" do
        expect(page).to have_current_path(decidim_decidim_awesome.required_authorizations_path(redirect_url: restricted_path))
        expect(page).to have_content("GRANTED VERIFICATIONS")
        expect(page).to have_content("NOT VERIFIED YET")
        expect(page).to have_no_content("PENDING VERIFICATIONS")
      end
    end

    context "when the user is authorized" do
      before do
        create(:authorization, :granted, user:, name: "dummy_authorization_handler")
        create(:authorization, :granted, user:, name: "another_dummy_authorization_handler")
        visit restricted_path
      end

      it "acts as normal" do
        expect(page).to have_current_path(restricted_path, ignore_query: true)
      end
    end

    context "when user is not confirmed" do
      let(:user) { create(:user, organization:) }

      it "acts as normal" do
        sleep 0.5
        expect(page).to have_content("Log in")
        expect(page).to have_current_path("/users/sign_in")
      end
    end

    context "when user is blocked" do
      let(:user) { create(:user, :confirmed, :blocked, organization:) }

      it "acts as normal" do
        expect(page).to have_content("This account has been blocked")
        expect(page).to have_current_path("/")
      end
    end

    context "when the verification method does not exist" do
      let!(:force_authorization_after_login) { create(:awesome_config, organization:, var: :force_authorization_after_login, value: %w(non_existent_authorization_handler)) }

      it "acts as normal" do
        expect(page).to have_current_path(restricted_path, ignore_query: true)
      end
    end
  end
end
