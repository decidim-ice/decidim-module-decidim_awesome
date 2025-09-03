# frozen_string_literal: true

require "spec_helper"

describe "Hashcash protector", :perform_enqueued do
  let(:organization) { create(:organization, available_locales: [:en]) }
  let!(:component) { create(:proposal_component, :with_creation_enabled, organization:) }
  let!(:awesome_hashcash_login) { create(:awesome_config, organization:, var: :hashcash_login, value: hashcash_login) }
  let!(:awesome_hashcash_signup) { create(:awesome_config, organization:, var: :hashcash_signup, value: hashcash_signup) }
  let!(:awesome_hashcash_login_bits) { create(:awesome_config, organization:, var: :hashcash_login_bits, value: hashcash_login_bits) }
  let!(:awesome_hashcash_signup_bits) { create(:awesome_config, organization:, var: :hashcash_signup_bits, value: hashcash_signup_bits) }
  let(:hashcash_login) { true }
  let(:hashcash_login_bits) { 30 }
  let(:hashcash_signup) { true }
  let(:hashcash_signup_bits) { 30 }
  let!(:user) { create(:user, :confirmed, organization:) }

  shared_examples "checking the form hidden fields" do
    it "adds the hidden hashcash field to the login form" do
      expect(page).to have_field("hashcash", type: :hidden)
      expect(page).to have_button("Waiting for verification ...", disabled: true)
    end

    it "adds the hidden hashcash field to the signup form" do
      within ".login__info, .login__modal-links" do
        click_on "Create an account"
      end

      expect(page).to have_field("hashcash", type: :hidden)
      expect(page).to have_button("Waiting for verification ...", disabled: true)
    end
  end

  before do
    switch_to_host(organization.host)
    visit decidim.new_user_session_path
  end

  context "when the user logs_in in session controller" do
    include_examples "checking the form hidden fields"
  end

  context "when the user logs_in inside a component" do
    before do
      switch_to_host(organization.host)
      visit main_component_path(component)
      click_on "New proposal"
    end

    include_examples "checking the form hidden fields"
  end

  context "when hashcash is resolved" do
    let(:hashcash_login_bits) { 10 }
    let(:hashcash_signup_bits) { 10 }

    it "can log in successfully" do
      within "#session_new_user" do
        fill_in :session_user_email, with: user.email
        fill_in :session_user_password, with: "decidim123456789"
        click_on "Log in"
      end
      expect(page).to have_content("Logged in successfully.")
    end

    it "adds the hidden hashcash field to the signup form" do
      within ".login__info" do
        click_on "Create an account"
      end

      within "#register-form" do
        fill_in :registration_user_name, with: "Bob"
        fill_in :registration_user_email, with: "bob@example.org"
        fill_in :registration_user_password, with: "decidim123456789"
        check :registration_user_tos_agreement
        check :registration_user_newsletter
        click_on "Create an account"
      end
      expect(page).to have_content("A message with a confirmation link has been sent to your email address.")
    end
  end

  context "when hashcash is disabled" do
    let(:hashcash_login) { false }
    let(:hashcash_signup) { false }

    it "does not add the hidden hashcash field to the login form" do
      expect(page).to have_no_field("hashcash", type: :hidden)
      within "#session_new_user" do
        fill_in :session_user_email, with: user.email
        fill_in :session_user_password, with: "decidim123456789"
        click_on "Log in"
      end
      expect(page).to have_content("Logged in successfully.")
    end

    it "does not add the hidden hashcash field to the signup form" do
      within ".login__info" do
        click_on "Create an account"
      end

      expect(page).to have_no_field("hashcash", type: :hidden)
      within "#register-form" do
        fill_in :registration_user_name, with: "Bob"
        fill_in :registration_user_email, with: "bob@example.org"
        fill_in :registration_user_password, with: "decidim123456789"
        check :registration_user_tos_agreement
        check :registration_user_newsletter
        click_on "Create an account"
      end
      expect(page).to have_content("A message with a confirmation link has been sent to your email address.")
    end
  end
end
