# frozen_string_literal: true

require "spec_helper"

describe "Scoped admin journeys", type: :system do
  let(:organization) { create :organization }
  let!(:assembly) { create(:assembly, organization: organization) }
  let!(:another_assembly) { create(:assembly, organization: organization) }
  let!(:participatory_process) { create(:participatory_process, organization: organization) }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  # let!(:admin) { create(:user, :confirmed, :admin, organization: organization) }
  let!(:config) { create :awesome_config, organization: organization, var: :scoped_admins, value: admins }
  let(:config_helper) { create :awesome_config, organization: organization, var: :scoped_admin_bar }
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

    switch_to_host(organization.host)
    login_as user, scope: :user
    # visit decidim_admin.root_path
  end

  shared_examples "admin terms can be accepted" do
    it "allows the admin root page" do
    end
  end

  shared_examples "redirects to index" do |_link|
    it "display admin index page" do
      expect(page).to have_content("You are not authorized to perform this action")
      expect(page).to have_content("Welcome to the Decidim Admin Panel.")
      expect(page).to have_current_path(decidim_admin.root_path, ignore_query: true)
    end
  end

  shared_examples "forbids awesome access" do
    it "does not have awesome link" do
      expect(page).not_to have_content("Decidim awesome")
    end

    describe "forbids module access" do
      before do
        visit decidim_admin_decidim_awesome.config_path(:editors)
      end

      it_behaves_like "redirects to index"
    end
  end

  shared_examples "forbids external accesses" do
    describe "forbids newsletter access" do
      before do
        visit decidim_admin.newsletters_path
      end

      it_behaves_like "redirects to index"
    end

    describe "forbids participants access" do
      before do
        decidim_admin.users_path
      end

      it_behaves_like "redirects to index"
    end

    describe "forbids pages access" do
      before do
        decidim_admin.static_pages_path
      end

      it_behaves_like "redirects to index"
    end

    describe "forbids moderation access" do
      before do
        decidim_admin.moderations_path
      end

      it_behaves_like "redirects to index"
    end

    describe "forbids organization access" do
      before do
        decidim_admin.edit_organization_path
      end

      it_behaves_like "redirects to index"
    end
  end

  shared_examples "allows all admin routes" do
    before do
      visit decidim_admin.root_path
    end

    it "allows the admin root page" do
      expect(page).to have_content("Welcome to the Decidim Admin Panel.")
    end

    it "allows the assemblies page" do
      click_link "Assemblies"

      expect(page).to have_content("New assembly")
    end

    it "allows the processes page" do
      click_link "Processes"

      expect(page).to have_content("New process")
    end

    it_behaves_like "forbids awesome access"
    it_behaves_like "forbids external accesses"
  end

  shared_examples "allows limited admin routes" do
    before do
      visit decidim_admin.root_path
    end

    it "allows the admin root page" do
      expect(page).to have_content("Welcome to the Decidim Admin Panel.")
    end

    it "allows the assemblies page" do
      click_link "Assemblies"

      expect(page).to have_content("New assembly")
    end

    describe "forbids processes" do
      before do
        click_link "Processes"
      end

      it_behaves_like "redirects to index"

      it "is not a process page" do
        expect(page).not_to have_content("New process")
      end
    end

    it_behaves_like "forbids awesome access"
    it_behaves_like "forbids external accesses"
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
      let!(:user) { create(:user, :confirmed, :admin_terms_accepted, organization: organization) }

      it_behaves_like "allows all admin routes"

      context "and there's constraints" do
        let(:settings) do
          {
            "participatory_space_manifest" => "assemblies",
            "participatory_space_slug" => assembly.slug
          }
        end

        it_behaves_like "allows limited admin routes"
      end
    end
  end
end
