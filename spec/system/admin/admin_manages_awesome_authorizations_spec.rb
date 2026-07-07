# frozen_string_literal: true

require "spec_helper"

describe "Admin manages awesome authorizations" do
  let(:organization) { create(:organization, available_authorizations: available_authorizations) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:available_authorizations) { [] }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  context "when awesome_authorization_handler is enabled" do
    before do
      allow(Decidim::DecidimAwesome.config).to receive(:awesome_authorization_handler).and_return(true)
      visit decidim_admin_decidim_awesome.awesome_authorizations_path
    end

    context "when authorization is available in organization" do
      let(:available_authorizations) { ["awesome_authorization_handler"] }

      it "does not show the not available callout" do
        expect(page).to have_no_selector(".callout.alert")
      end

      it "shows the page title" do
        expect(page).to have_content("Awesome authorizations")
      end

      it "allows updating authorization properties" do
        locale = organization.default_locale

        visit decidim_admin_decidim_awesome.awesome_authorization_properties_path

        fill_in "awesome_authorization_properties_name_#{locale}", with: "Organization groups"
        fill_in "awesome_authorization_properties_explanation_#{locale}", with: "Custom description for this authorization"
        click_on "Save"

        expect(page).to have_content("updated successfully")
        expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: :awesome_authorization_handler)&.value).to include(
          {
            "name" => include(locale.to_s => "Organization groups"),
            "explanation" => include(locale.to_s => "Custom description for this authorization")
          }
        )
      end

      it "allows creating an authorization group" do
        click_on "Create a new authorization group"

        fill_in_i18n :awesome_authorization_group_name,
                     "#awesome_authorization_group-name-tabs",
                     en: "Residents"
        fill_in_i18n :awesome_authorization_group_purpose,
                     "#awesome_authorization_group-name-tabs",
                     en: "People registered in the city"
        click_on "Create"

        expect(page).to have_content("Authorization group created successfully")
        expect(page).to have_content("Residents")

        group = organization.awesome_authorization_groups.order(:id).last
        expect(group.name["en"]).to eq("Residents")
        expect(group.purpose["en"]).to eq("People registered in the city")
      end

      it "allows editing an authorization group" do
        group = create(:awesome_authorization_group, organization:)

        visit decidim_admin_decidim_awesome.awesome_authorizations_path
        click_link_or_button "Edit group"

        fill_in_i18n :awesome_authorization_group_name,
                     "#awesome_authorization_group-name-tabs",
                     en: "Verified residents"
        fill_in_i18n :awesome_authorization_group_purpose,
                     "#awesome_authorization_group-name-tabs",
                     en: "Residents verified by the city"
        click_on "Save"

        expect(page).to have_content("Authorization group updated successfully")

        group.reload
        expect(group.name["en"]).to eq("Verified residents")
        expect(group.purpose["en"]).to eq("Residents verified by the city")
      end

      it "allows destroying an authorization group" do
        create(:awesome_authorization_group, organization:)

        visit decidim_admin_decidim_awesome.awesome_authorizations_path

        accept_confirm do
          click_link_or_button "Destroy group"
        end

        expect(page).to have_content("Authorization group removed successfully")
        expect(Decidim::DecidimAwesome::AuthorizationGroup.count).to eq(0)
      end

      it "allows managing members in a group" do
        group = create(:awesome_authorization_group, organization:)

        visit decidim_admin_decidim_awesome.awesome_authorization_users_path(group)

        expect(page).to have_content("This group has no members yet")

        click_on "Add new members"
        fill_in "awesome_authorization_members_emails", with: "alice@example.org\nbob@example.org"
        click_on "Add members"

        expect(page).to have_content("Members list updated successfully")
        expect(page).to have_content("alice@example.org")
        expect(page).to have_content("bob@example.org")

        expect do
          within("tr", text: "alice@example.org") do
            accept_confirm do
              click_link_or_button "Remove member"
            end
          end
        end.to change(Decidim::DecidimAwesome::AuthorizationMember, :count).by(-1)

        expect(page).to have_content("Member removed successfully")
      end

      it "shows an out of sync warning when members and granted authorizations mismatch" do
        group = create(:awesome_authorization_group, organization:)
        create(:awesome_authorization_member, authorization_group: group, email: admin.email)

        visit decidim_admin_decidim_awesome.awesome_authorization_users_path(group)

        expect(page).to have_content("out of sync with this authorization group")
      end
    end

    context "when authorization is not available in organization" do
      it "shows the not available callout" do
        expect(page).to have_css(".callout.alert")
        expect(page).to have_content("In order to use this feature, you must enable the awesome authorization workflow")
      end

      it "shows a link to system admin" do
        expect(page).to have_link("System admin", href: %r{/system/organizations/.+/edit})
      end
    end
  end

  context "when awesome_authorization_handler is disabled" do
    before do
      allow(Decidim::DecidimAwesome.config).to receive(:awesome_authorization_handler).and_return(false)
    end

    it "shows the page (permission check happens at authorization level)" do
      visit decidim_admin_decidim_awesome.awesome_authorizations_path
      expect(page).to have_current_path(decidim_admin_decidim_awesome.awesome_authorizations_path)
      expect(page).to have_content("Awesome authorizations")
    end
  end
end
