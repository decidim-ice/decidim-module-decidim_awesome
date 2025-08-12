# frozen_string_literal: true

require "spec_helper"

describe "Forced verifications" do
  let(:organization) { create(:organization, available_authorizations: [:dummy_authorization_handler, :another_dummy_authorization_handler]) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let(:restricted_path) { "/" }
  let(:key) { "default" }
  let!(:authorization_groups_config) do
    create(
      :awesome_config,
      organization:,
      var: :authorization_groups,
      value: {
        key => {
          "authorization_handlers" => {
            "dummy_authorization_handler" => { "options" => {} },
            "another_dummy_authorization_handler" => { "options" => {} }
          },
          "force_authorization_with_any_method" => any_method,
          "force_authorization_help_text" => { en: "Help text <strong>with HTML</strong>" }
        },
        "invalid" => {
          "authorization_handlers" => ["non_existent_authorization_handler"],
          "force_authorization_help_text" => { en: "Won't show" }
        }
      }
    )
  end
  let!(:force_authorization_with_any_method) { create(:awesome_config, organization:, var: :force_authorization_with_any_method, value: any_method) }
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

    # TODO: Check it
    # it "user can logout" do
    #   click_on "let me logout"
    #   expect(page).to have_current_path("/")
    # end

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

    context "when the user has not accepted the terms an conditions" do
      let(:user) { create(:user, :confirmed, organization:, accepted_tos_version: nil) }

      it "user can accept the terms and conditions" do
        expect(page).to have_current_path("/pages/terms-of-service")
        click_on "I agree with these terms"
        sleep 1
        expect(user.reload.accepted_tos_version).not_to be_nil
        expect(page).to have_current_path(decidim_decidim_awesome.required_authorizations_path(redirect_url: restricted_path))
        expect(page).to have_content("you need to authorize your account with a valid authorization")
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
      let!(:authorization_groups_config) { create(:awesome_config, organization:, var: :authorization_groups, value: authorization_groups_value) }
      let(:authorization_groups_value) do
        {
          "default" => {
            "authorization_handlers" => {
              "id_documents" => { "options" => {} },
              "dummy_authorization_handler" => { "options" => {} }
            },
            "force_authorization_help_text" => { en: "Help text <strong>with HTML 2</strong>" }
          }
        }
      end

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
      let!(:authorization_groups_config) { create(:awesome_config, organization:, var: :authorization_groups, value: authorization_groups_value) }
      let(:authorization_groups_value) do
        {
          "default" => {
            "authorization_handlers" => {
              "non_existent_authorization_handler" => { "options" => {} }
            }
          }
        }
      end

      it "acts as normal" do
        expect(page).to have_current_path(restricted_path, ignore_query: true)
      end
    end

    context "with constraints scenarios" do
      let(:organization) { create(:organization, available_authorizations: [:id_documents]) }
      let!(:user) { create(:user, :confirmed, organization: organization) }
      let(:process) { create(:participatory_process, :with_steps, organization:) }
      let(:assembly) { create(:assembly, organization:) }
      let!(:process_component) { create(:component, manifest_name: :proposals, participatory_space: process) }
      let!(:assembly_component) { create(:component, manifest_name: :meetings, participatory_space: assembly) }
      let(:authorization_groups_value) do
        { "test" => { "authorization_handlers" => { "id_documents" => { "options" => {} } } } }
      end
      let!(:group_subconfig) { create(:awesome_config, organization:, var: "authorization_group_test", value: nil) }

      before do
        authorization_groups_config.update!(value: authorization_groups_value)
      end

      it "applies everywhere when there are no constraints (always)" do
        visit restricted_path
        expect(page).to have_current_path(decidim_decidim_awesome.required_authorizations_path(redirect_url: restricted_path))
      end

      it "never applies when a 'none' constraint is present" do
        create(:config_constraint, awesome_config: group_subconfig, settings: { "participatory_space_manifest" => "none" })

        visit restricted_path
        expect(page).to have_current_path(restricted_path, ignore_query: true)
      end

      it "assemblies manifest requires auth on assembly, not on processes" do
        create(:config_constraint, awesome_config: group_subconfig, settings: { "participatory_space_manifest" => "assemblies" })

        visit decidim_assemblies.assembly_path(assembly)
        expect(page).to have_current_path(decidim_decidim_awesome.required_authorizations_path, ignore_query: true)

        visit decidim_participatory_processes.participatory_process_path(process)
        expect(page).to have_current_path(decidim_participatory_processes.participatory_process_path(process))
      end

      it "specific space (participatory process) requires auth on that process only" do
        create(:config_constraint, awesome_config: group_subconfig, settings: { "participatory_space_id" => process.id })

        visit decidim_participatory_processes.participatory_process_path(process)
        expect(page).to have_current_path(decidim_decidim_awesome.required_authorizations_path, ignore_query: true)

        other = create(:participatory_process, :with_steps, organization:)
        visit decidim_participatory_processes.participatory_process_path(other)
        expect(page).to have_current_path(decidim_participatory_processes.participatory_process_path(other))
      end

      it "specific assembly requires auth on that assembly only" do
        create(:config_constraint, awesome_config: group_subconfig, settings: { "participatory_space_id" => assembly.id })

        visit decidim_assemblies.assembly_path(assembly)
        expect(page).to have_current_path(decidim_decidim_awesome.required_authorizations_path, ignore_query: true)

        other = create(:assembly, organization:)
        visit decidim_assemblies.assembly_path(other)
        expect(page).to have_current_path(decidim_assemblies.assembly_path(other))
      end

      it "specific component in specific process requires auth only there" do
        create(:config_constraint, awesome_config: group_subconfig, settings: { "participatory_space_id" => process.id, "component_manifest" => process_component.manifest.name.to_s })

        visit Decidim::EngineRouter.main_proxy(process_component).root_path
        expect(page).to have_current_path(decidim_decidim_awesome.required_authorizations_path, ignore_query: true)

        visit decidim_participatory_processes.participatory_process_path(process)
        expect(page).to have_current_path(decidim_participatory_processes.participatory_process_path(process))
      end

      it "specific component in specific assembly requires auth only there" do
        create(:config_constraint, awesome_config: group_subconfig, settings: { "participatory_space_id" => assembly.id, "component_manifest" => assembly_component.manifest.name.to_s })

        visit Decidim::EngineRouter.main_proxy(assembly_component).root_path
        expect(page).to have_current_path(decidim_decidim_awesome.required_authorizations_path, ignore_query: true)

        visit decidim_assemblies.assembly_path(assembly)
        expect(page).to have_current_path(decidim_assemblies.assembly_path(assembly))
      end

      it "everywhere except participatory spaces does not trigger on processes" do
        create(:config_constraint, awesome_config: group_subconfig, settings: { "participatory_space_manifest" => "system" })

        visit decidim_assemblies.assembly_path(assembly)
        expect(page).to have_current_path(decidim_decidim_awesome.required_authorizations_path, ignore_query: true)

        visit decidim_participatory_processes.participatory_processes_path
        expect(page).to have_current_path(decidim_participatory_processes.participatory_processes_path)
      end

      it "participatory process groups require auth at group page" do
        group = create(:participatory_process_group, organization:)
        process.update!(participatory_process_group: group)

        create(:config_constraint, awesome_config: group_subconfig, settings: { "participatory_space_manifest" => "process_groups" })

        visit decidim_participatory_processes.participatory_process_group_path(group)
        expect(page).to have_current_path(decidim_decidim_awesome.required_authorizations_path, ignore_query: true)
      end
    end
  end
end
