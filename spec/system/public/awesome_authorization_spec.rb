# frozen_string_literal: true

require "spec_helper"

describe "Awesome authorization" do
  let(:organization) { create(:organization, available_authorizations: ["awesome_authorization_handler"]) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:authorization_group) { create(:awesome_authorization_group, organization:) }

  before do
    switch_to_host(organization.host)
  end

  context "when user is not logged in" do
    it "requires login to authorize" do
      visit decidim_verifications.authorizations_path
      expect(page).to have_current_path(decidim.new_user_session_path)
    end
  end

  context "when user is logged in" do
    before do
      login_as user, scope: :user
    end

    context "when user does not belong to any group" do
      it "cannot authorize" do
        visit decidim_verifications.authorizations_path
        click_link_or_button I18n.t("decidim.authorization_handlers.awesome_authorization_handler.name")
        click_link_or_button "Send"

        expect(page).to have_content(I18n.t("decidim.decidim_awesome.awesome_authorization_handler.errors.user_not_in_group", email: user.email))
      end
    end

    context "when user belongs to a group" do
      before do
        create(:awesome_authorization_member, authorization_group:, email: user.email)
      end

      it "can authorize" do
        visit decidim_verifications.authorizations_path
        click_link_or_button I18n.t("decidim.authorization_handlers.awesome_authorization_handler.name")
        click_link_or_button "Send"

        expect(page).to have_content("You have been successfully authorized")

        authorization = Decidim::Authorization.find_by(user:, name: "awesome_authorization_handler")
        expect(authorization).to be_present
        expect(authorization.metadata[:groups]).to be_a(Hash)
        expect(authorization.metadata[:groups].keys).to include(authorization_group.id.to_s)
      end
    end

    context "when user is already authorized" do
      before do
        create(:awesome_authorization_member, authorization_group:, email: user.email)
        create(:authorization, user:, name: "awesome_authorization_handler")
      end

      it "shows existing authorization" do
        visit decidim_verifications.authorizations_path

        expect(page).to have_content("Organization Group's Authorization")
      end
    end
  end
end
