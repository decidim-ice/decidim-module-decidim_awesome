# frozen_string_literal: true

require "spec_helper"

describe "Admin manages awesome authorizations permissions in the admin" do
  let(:organization) { create(:organization, available_authorizations: available_authorizations) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:available_authorizations) { [] }
  let!(:awesome_authorization_group) { create(:awesome_authorization_group, name: { en: "Board members" }, organization:) }
  let!(:awesome_authorization_group2) { create(:awesome_authorization_group, name: { en: "Staff" }, organization:) }
  let!(:config) { create(:awesome_config, organization:, var: :awesome_authorization_handler, value: handler_config) }
  let(:handler_config) do
    {
      "name" => { en: "Members of the organization" },
      "description" => { en: "Members of the organization" }
    }
  end
  let(:participatory_process) { create(:participatory_process, organization:) }
  let!(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
  let!(:elections_component) { create(:elections_component, participatory_space: participatory_process) }
  let!(:election) { create(:election, :with_questions, census_manifest: "internal_users", component: elections_component) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_participatory_processes.edit_component_permissions_path(participatory_process, proposal_component)
  end

  context "when the organization has not enabled the awesome authorization" do
    it "does not show the awesome authorization permissions in the admin" do
      expect(page).to have_no_content("Members of the organization")
    end
  end

  context "when the organization has enabled the awesome authorization" do
    let(:available_authorizations) { ["awesome_authorization_handler"] }

    it "Groups can be selected in the component's permissions" do
      expect(page).to have_content("Members of the organization (Direct)")
      check "component_permissions_permissions_like_authorization_handlers_awesome_authorization_handler"
      expect(page).to have_no_content("Board members")
      expect(page).to have_no_content("Staff")
      tom_select("#component_permissions_permissions_like_authorization_handlers_options_awesome_authorization_handler_awesome_authorization_groups", option_id: awesome_authorization_group.id)
      expect(page).to have_content("Board members")
      click_on "Submit"
      component_permissions = proposal_component.reload.permissions
      selected_groups = component_permissions.dig("like", "authorization_handlers", "awesome_authorization_handler", "options", "awesome_authorization_groups").to_s.split(",")
      expect(selected_groups).to include(awesome_authorization_group.id.to_s)
      expect(selected_groups).not_to include(awesome_authorization_group2.id.to_s)
    end

    context "when permissions are already set" do
      before do
        proposal_component.update!(
          permissions: {
            "like" => {
              "authorization_handlers" => {
                "awesome_authorization_handler" => {
                  "options" => { "awesome_authorization_groups" => "#{awesome_authorization_group.id},#{awesome_authorization_group2.id}" }
                }
              }
            }
          }
        )
        visit decidim_admin_participatory_processes.edit_component_permissions_path(participatory_process, proposal_component)
      end

      it "shows the selected groups in the component's permissions" do
        expect(page).to have_content("Members of the organization (Direct)")
        expect(page).to have_content("Board members")
        expect(page).to have_content("Staff")
      end
    end

    context "when editing the election's census permissions" do
      it "Groups can be selected in the census permissions" do
        visit manage_component_path(elections_component)
        within "tr[data-id='#{election.id}']" do
          find("button[data-controller='dropdown']").click
          click_on "Edit election"
        end
        click_on "Census"
        expect(page).to have_content("Members of the organization (Direct)")
        check "internal_users_authorization_handlers_names_awesome_authorization_handler"
        expect(page).to have_no_content("Board members")
        expect(page).to have_no_content("Staff")
        tom_select("#internal_users_authorization_handlers_options_awesome_authorization_handler_awesome_authorization_groups", option_id: awesome_authorization_group.id)
        expect(page).to have_content("Board members")
        click_on "Save and continue"
        settings = election.reload.census_settings
        selected_groups = settings.dig("authorization_handlers", "awesome_authorization_handler", "options", "awesome_authorization_groups").to_s.split(",")
        expect(selected_groups).to include(awesome_authorization_group.id.to_s)
        expect(selected_groups).not_to include(awesome_authorization_group2.id.to_s)
      end
    end
  end
end
