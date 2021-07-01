# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/scoped_admins_examples"

describe "Scoped admin journeys", type: :system do
  let(:organization) { create :organization }
  let!(:assembly) { create(:assembly, organization: organization) }
  let!(:component) { create(:proposal_component, participatory_space: assembly) }
  let!(:proposal) { create(:proposal, :official, component: component) }
  let!(:another_component) { create(:meeting_component, participatory_space: assembly) }
  let!(:another_assembly) { create(:assembly, organization: organization) }
  let!(:participatory_process) { create(:participatory_process, organization: organization) }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:user_accepted) { create(:user, :confirmed, :admin_terms_accepted, organization: organization) }
  let!(:admin) { create(:user, :confirmed, :admin, organization: organization) }
  let!(:config) { create :awesome_config, organization: organization, var: :scoped_admins, value: admins }
  let(:config_helper) { create :awesome_config, organization: organization, var: :scoped_admin_bar, value: nil }
  let!(:constraint) { create(:config_constraint, awesome_config: config_helper, settings: settings) }
  let(:admins) do
    {
      "bar" => []
    }
  end
  let(:settings) do
    {}
  end

  before do
    # ErrorController is only called when in production mode
    allow(Rails.application).to \
      receive(:env_config).with(no_args).and_wrap_original do |m, *|
        m.call.merge(
          "action_dispatch.show_exceptions" => true,
          "action_dispatch.show_detailed_exceptions" => false
        )
      end

    component.update!(default_step_settings: { creation_enabled: true })
    another_component.update!(default_step_settings: { creation_enabled: true })
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when is not a scoped admin" do
    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_admin.root_path }
    end
  end

  context "when is a scoped admin" do
    let(:admins) do
      {
        "bar" => [user.id.to_s]
      }
    end

    context "and scope is 'none'" do
      let(:settings) do
        {
          "participatory_space_manifest" => "none"
        }
      end

      it_behaves_like "a 404 page" do
        let(:target_path) { decidim_admin.root_path }
      end
    end

    context "and admin terms not accepted" do
      it "allows admin terms to be accepted" do
        visit decidim_admin.root_path

        expect(page).to have_content("Welcome to the Decidim Admin Panel.")

        click_link "Review them now"

        expect(page).to have_content("Agree to the terms and conditions of use")

        click_button "I agree with the following terms"

        expect(page).to have_content("Welcome to the Decidim Admin Panel.")
        expect(page).not_to have_content("Review them now")
      end
    end

    context "and admin terms are accepted" do
      let(:user) { user_accepted }

      it_behaves_like "allows all admin routes"
      it_behaves_like "allows external accesses"
      it_behaves_like "forbids awesome access"
      it_behaves_like "edits all assemblies"

      context "and there's constraints" do
        let(:settings) do
          {
            "participatory_space_manifest" => "assemblies",
            "participatory_space_slug" => assembly.slug
          }
        end

        it_behaves_like "allows limited admin routes"
        it_behaves_like "shows partial admin links in the frontend"
        it_behaves_like "edits allowed assemblies"

        context "and user is a real admin" do
          let(:user) { admin }

          it_behaves_like "allows all admin routes"
          it_behaves_like "allows external accesses"
          it_behaves_like "allows awesome access"
          it_behaves_like "edits all assemblies"
        end

        context "and scoped to a component" do
          let(:settings) do
            {
              "participatory_space_manifest" => "assemblies",
              "participatory_space_slug" => assembly.slug,
              "component_manifest" => "proposals"
            }
          end

          it_behaves_like "allows limited admin routes"
          it_behaves_like "shows component partial admin links in the frontend"
          it_behaves_like "edits allowed components"
        end
      end
    end
  end
end
