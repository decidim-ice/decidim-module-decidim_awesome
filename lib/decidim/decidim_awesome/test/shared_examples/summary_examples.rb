# frozen_string_literal: true

shared_examples "registered components" do |enabled|
  if enabled
    it "has components registered" do
      expect(Decidim.component_manifests.pluck(:name)).to include(:awesome_map)
      expect(Decidim.component_manifests.pluck(:name)).to include(:awesome_iframe)
    end

    it "has map content block is registered" do
      expect(Decidim.content_blocks.for(:homepage).pluck(:name)).to include(:awesome_map)
    end
  else
    it "components are not registered" do
      expect(Decidim.component_manifests.pluck(:name)).not_to include(:awesome_map)
      expect(Decidim.component_manifests.pluck(:name)).not_to include(:awesome_iframe)
    end

    it "map content block is not registered" do
      expect(Decidim.content_blocks.for(:homepage).pluck(:name)).not_to include(:awesome_map)
    end
  end
end

shared_examples "activated concerns" do |enabled|
  it "common concerns are registered" do
    expect(ActionView::Base.included_modules).to include(Decidim::DecidimAwesome::AwesomeHelpers)
    expect(Decidim::ViewModel.included_modules).to include(Decidim::DecidimAwesome::AwesomeHelpers)
    expect(Decidim::ApplicationController.included_modules).to include(Decidim::DecidimAwesome::ContentSecurityPolicy)
    expect(Decidim::Admin::ApplicationController.included_modules).to include(Decidim::DecidimAwesome::ContentSecurityPolicy)
  end

  if enabled
    it "concerns are registered" do
      expect(Decidim::User.included_modules).to include(Decidim::DecidimAwesome::UserOverride)
      expect(Decidim::MenuPresenter.included_modules).to include(Decidim::DecidimAwesome::MenuPresenterOverride)
      expect(Decidim::MenuItemPresenter.included_modules).to include(Decidim::DecidimAwesome::MenuItemPresenterOverride)
      expect(Decidim::ErrorsController.included_modules).to include(Decidim::DecidimAwesome::NotFoundRedirect)
      expect(Decidim::Proposals::ApplicationHelper.included_modules).to include(Decidim::DecidimAwesome::Proposals::ApplicationHelperOverride)
      expect(Decidim::Proposals::ProposalForm.included_modules).to include(Decidim::DecidimAwesome::Proposals::ProposalFormCustomizations)
      expect(Decidim::Proposals::Admin::ProposalForm.included_modules).to include(Decidim::DecidimAwesome::Proposals::Admin::ProposalFormCustomizations)
      expect(Decidim::Proposals::ProposalForm.included_modules).to include(Decidim::DecidimAwesome::Proposals::ProposalFormOverride)
      expect(Decidim::Proposals::Admin::ProposalForm.included_modules).to include(Decidim::DecidimAwesome::Proposals::ProposalFormOverride)
      expect(Decidim::AmendmentsHelper.included_modules).to include(Decidim::DecidimAwesome::AmendmentsHelperOverride)
      expect(EtiquetteValidator.included_modules).to include(Decidim::DecidimAwesome::EtiquetteValidatorOverride)
      expect(Decidim::Proposals::ProposalVote.included_modules).to include(Decidim::DecidimAwesome::HasVoteWeight)
      expect(Decidim::Proposals::ProposalType.included_modules).to include(Decidim::DecidimAwesome::AddProposalTypeVoteWeights)
      expect(Decidim::Proposals::ProposalType.included_modules).to include(Decidim::DecidimAwesome::AddProposalTypeCustomFields)
      expect(Decidim::Proposals::ProposalLCell.included_modules).to include(Decidim::DecidimAwesome::ProposalLCellOverride)
      expect(Decidim::Proposals::Proposal.included_modules).to include(Decidim::DecidimAwesome::HasProposalExtraFields)
      expect(Decidim::Proposals::CollaborativeDraft.included_modules).to include(Decidim::DecidimAwesome::HasProposalExtraFields)
      expect(Decidim::ContentBlocks::GlobalMenuCell.included_modules).to include(Decidim::DecidimAwesome::GlobalMenuCellOverride)
      expect(Decidim::BreadcrumbHelper.included_modules).to include(Decidim::DecidimAwesome::BreadcrumbHelperOverride)
      expect(Decidim::BreadcrumbRootMenuItemPresenter.included_modules).to include(Decidim::DecidimAwesome::BreadcrumbRootMenuItemPresenterOverride)
      expect(Decidim::Proposals::ProposalSerializer.included_modules).to include(Decidim::DecidimAwesome::Proposals::ProposalSerializerOverride)
      expect(Decidim::Proposals::ProposalVotesController.included_modules).to include(Decidim::DecidimAwesome::Proposals::ProposalVotesControllerOverride)
      expect(Decidim::AmendmentsController.included_modules).to include(Decidim::DecidimAwesome::LimitPendingAmendments)
      expect(Decidim::Proposals::ProposalsController.included_modules).to include(Decidim::DecidimAwesome::Proposals::OrderableOverride)
      expect(Decidim::AdminLog::ComponentPresenter.included_modules).to include(Decidim::DecidimAwesome::AdminLog::ComponentPresenterOverride)
      expect(Decidim::ApplicationController.included_modules).to include(Decidim::DecidimAwesome::EnforceAccessAuthorizations)
      expect(Decidim::ApplicationController.included_modules).to include(Decidim::DecidimAwesome::UseUserTimeZone)
      expect(Decidim::AccountForm.included_modules).to include(Decidim::DecidimAwesome::AccountFormOverride)
      expect(Decidim::UpdateAccount.included_modules).to include(Decidim::DecidimAwesome::UpdateAccountOverride)
      expect(Decidim::System::RegisterOrganizationForm.included_modules).to include(Decidim::DecidimAwesome::System::OrganizationFormOverride)
      expect(Decidim::System::UpdateOrganizationForm.included_modules).to include(Decidim::DecidimAwesome::System::OrganizationFormOverride)
      expect(Decidim::System::UpdateOrganization.included_modules).to include(Decidim::DecidimAwesome::System::UpdateOrganizationOverride)
      expect(Decidim::System::CreateOrganization.included_modules).to include(Decidim::DecidimAwesome::System::CreateOrganizationOverride)
      expect(Decidim::AdminLog::UserPresenter.included_modules).to include(Decidim::DecidimAwesome::AdminLog::UserPresenterOverride)
      expect(Decidim::Devise::SessionsController.included_modules).to include(Decidim::DecidimAwesome::NeedsHashcash)
      expect(Decidim::Devise::RegistrationsController.included_modules).to include(Decidim::DecidimAwesome::NeedsHashcash)
      expect(Decidim::LastActivity.included_modules).to include(Decidim::DecidimAwesome::LastActivityOverride)
    end

  else
    it "concerns are not registered" do
      expect(Decidim::User.included_modules).not_to include(Decidim::DecidimAwesome::UserOverride)
      expect(Decidim::MenuPresenter.included_modules).not_to include(Decidim::DecidimAwesome::MenuPresenterOverride)
      expect(Decidim::MenuItemPresenter.included_modules).not_to include(Decidim::DecidimAwesome::MenuItemPresenterOverride)
      expect(Decidim::ErrorsController.included_modules).not_to include(Decidim::DecidimAwesome::NotFoundRedirect)
      expect(Decidim::Proposals::ApplicationHelper.included_modules).not_to include(Decidim::DecidimAwesome::Proposals::ApplicationHelperOverride)
      expect(Decidim::Proposals::ProposalForm.included_modules).not_to include(Decidim::DecidimAwesome::Proposals::ProposalFormCustomizations)
      expect(Decidim::Proposals::Admin::ProposalForm.included_modules).not_to include(Decidim::DecidimAwesome::Proposals::Admin::ProposalFormCustomizations)
      expect(Decidim::Proposals::ProposalForm.included_modules).not_to include(Decidim::DecidimAwesome::Proposals::ProposalFormOverride)
      expect(Decidim::Proposals::Admin::ProposalForm.included_modules).not_to include(Decidim::DecidimAwesome::Proposals::ProposalFormOverride)
      expect(Decidim::AmendmentsHelper.included_modules).not_to include(Decidim::DecidimAwesome::AmendmentsHelperOverride)
      expect(EtiquetteValidator.included_modules).not_to include(Decidim::DecidimAwesome::EtiquetteValidatorOverride)
      expect(Decidim::Proposals::ProposalVote.included_modules).not_to include(Decidim::DecidimAwesome::HasVoteWeight)
      expect(Decidim::Proposals::ProposalType.included_modules).not_to include(Decidim::DecidimAwesome::AddProposalTypeVoteWeights)
      expect(Decidim::Proposals::ProposalType.included_modules).not_to include(Decidim::DecidimAwesome::AddProposalTypeCustomFields)
      expect(Decidim::Proposals::ProposalLCell.included_modules).not_to include(Decidim::DecidimAwesome::ProposalLCellOverride)
      expect(Decidim::Proposals::Proposal.included_modules).not_to include(Decidim::DecidimAwesome::HasProposalExtraFields)
      expect(Decidim::Proposals::CollaborativeDraft.included_modules).not_to include(Decidim::DecidimAwesome::HasProposalExtraFields)
      expect(Decidim::ContentBlocks::GlobalMenuCell.included_modules).not_to include(Decidim::DecidimAwesome::GlobalMenuCellOverride)
      expect(Decidim::BreadcrumbHelper.included_modules).not_to include(Decidim::DecidimAwesome::BreadcrumbHelperOverride)
      expect(Decidim::BreadcrumbRootMenuItemPresenter.included_modules).not_to include(Decidim::DecidimAwesome::BreadcrumbRootMenuItemPresenterOverride)
      expect(Decidim::Proposals::ProposalSerializer.included_modules).not_to include(Decidim::DecidimAwesome::Proposals::ProposalSerializerOverride)
      expect(Decidim::Proposals::ProposalVotesController.included_modules).not_to include(Decidim::DecidimAwesome::Proposals::ProposalVotesControllerOverride)
      expect(Decidim::AmendmentsController.included_modules).not_to include(Decidim::DecidimAwesome::LimitPendingAmendments)
      expect(Decidim::Proposals::ProposalsController.included_modules).not_to include(Decidim::DecidimAwesome::Proposals::OrderableOverride)
      expect(Decidim::AdminLog::ComponentPresenter.included_modules).not_to include(Decidim::DecidimAwesome::AdminLog::ComponentPresenterOverride)
      expect(Decidim::ApplicationController.included_modules).not_to include(Decidim::DecidimAwesome::EnforceAccessAuthorizations)
      expect(Decidim::ApplicationController.included_modules).not_to include(Decidim::DecidimAwesome::UseUserTimeZone)
      expect(Decidim::AccountForm.included_modules).not_to include(Decidim::DecidimAwesome::AccountFormOverride)
      expect(Decidim::UpdateAccount.included_modules).not_to include(Decidim::DecidimAwesome::UpdateAccountOverride)
      expect(Decidim::System::RegisterOrganizationForm.included_modules).not_to include(Decidim::DecidimAwesome::System::OrganizationFormOverride)
      expect(Decidim::System::UpdateOrganizationForm.included_modules).not_to include(Decidim::DecidimAwesome::System::OrganizationFormOverride)
      expect(Decidim::System::UpdateOrganization.included_modules).not_to include(Decidim::DecidimAwesome::System::UpdateOrganizationOverride)
      expect(Decidim::DecidimAwesome::AwesomeHelpers.included_modules).not_to include(Decidim::DecidimAwesome::AwesomeHelpers)
      expect(Decidim::DecidimAwesome::ContentSecurityPolicy.included_modules).not_to include(Decidim::DecidimAwesome::ContentSecurityPolicy)
      expect(Decidim::DecidimAwesome::UserOverride.included_modules).not_to include(Decidim::DecidimAwesome::UserOverride)
      expect(Decidim::AdminLog::UserPresenter.included_modules).not_to include(Decidim::DecidimAwesome::AdminLog::UserPresenterOverride)
      expect(Decidim::Devise::SessionsController.included_modules).not_to include(Decidim::DecidimAwesome::NeedsHashcash)
      expect(Decidim::Devise::RegistrationsController.included_modules).not_to include(Decidim::DecidimAwesome::NeedsHashcash)
      expect(Decidim::LastActivity.included_modules).not_to include(Decidim::DecidimAwesome::LastActivityOverride)
    end
  end
end

shared_examples "csp directives" do |enabled|
  let(:organization) { create(:organization) }
  let(:fonts) { controller.content_security_policy.send(:policy)["font-src"] }
  let(:scripts) { controller.content_security_policy.send(:policy)["script-src"] }
  let(:frames) { controller.content_security_policy.send(:policy)["frame-src"] }

  shared_examples "controller directives" do
    if enabled
      it "has CSP directives" do
        get :show do
          expect(fonts).to eq(["'self'", "data:"])
          expect(scripts).to eq(["'self'", "'unsafe-inline'", "'unsafe-eval'", "https://www.intergram.xyz"])
          expect(frames).to eq(["'self'", "www.youtube-nocookie.com", "player.vimeo.com", "https://www.intergram.xyz"])
        end
      end
    else
      it "has no CSP directives" do
        get :show do
          expect(fonts).to eq(["'self'"])
          expect(scripts).to eq(["'self'", "'unsafe-inline'", "'unsafe-eval'"])
          expect(frames).to eq(["'self'", "www.youtube-nocookie.com", "player.vimeo.com"])
        end
      end
    end
  end

  describe Decidim::HomepageController, type: :controller do
    routes { Decidim::Core::Engine.routes }
    before do
      request.env["decidim.current_organization"] = user.organization
    end

    it_behaves_like "controller directives"
  end

  describe Decidim::Admin::DashboardController, type: :controller do
    routes { Decidim::Admin::Engine.routes }

    before do
      request.env["decidim.current_organization"] = user.organization
    end

    it_behaves_like "controller directives"
  end
end

shared_examples "custom menus" do |enabled|
  describe Decidim::MenuPresenter, type: :helper do
    before do
      allow(view).to receive(:current_organization).and_return(organization)
      allow(view).to receive(:current_user).and_return(user)
    end

    if enabled
      it "MenuPresenter returns an instance of MenuHacker" do
        expect(Decidim::MenuPresenter.new(:menu, view).evaluated_menu).to be_a(Decidim::DecidimAwesome::MenuHacker)
      end
    else
      it "MenuPresenter returns an instance of Decidim::Menu" do
        expect(Decidim::MenuPresenter.new(:menu, view).evaluated_menu).to be_a(Decidim::Menu)
      end
    end
  end
end

shared_examples "basic rendering" do |enabled|
  describe "shows public pages", type: :system do
    let(:boolean_vars) do
      [
        :allow_images_in_proposals,
        :allow_videos_in_editors,
        :allow_images_in_editors,
        :auto_save_forms
      ]
    end

    before do
      switch_to_host(organization.host)
      visit decidim.root_path
    end

    it "renders the home page" do
      expect(page).to have_content("Welcome to")
    end

    it "has DecidimAwesome object" do
      expect(page.body).to have_content("window.DecidimAwesome")
    end

    it "has DecidimAwesome javascript and CSS" do
      expect(page).to have_xpath("//link[@rel='stylesheet'][contains(@href,'decidim_decidim_awesome')]", visible: :all)
      expect(page).to have_xpath("//script[contains(@src,'decidim_decidim_awesome')]", visible: :all)
    end

    if enabled
      it "has boolean configs enabled" do
        boolean_vars.each do |var|
          expect(page.body).to have_content("\"#{var}\":true")
        end
      end

      it "has custom fields javascript" do
        expect(page).to have_xpath("//script[contains(@src,'decidim_decidim_awesome_custom_fields')]", visible: :all)
      end

      it "has custom styles CSS" do
        expect(page.body).to have_content(styles)
      end
    else
      it "has boolean configs disabled" do
        boolean_vars.each do |var|
          expect(page.body).to have_content("\"#{var}\":false")
        end
      end

      it "do not have custom fields javascript" do
        expect(page).to have_no_xpath("//script[contains(@src,'decidim_decidim_awesome_custom_fields')]", visible: :all)
      end

      it "do not have custom styles CSS" do
        expect(page.body).to have_no_content(styles)
      end
    end
  end

  describe "shows admin pages", type: :system do
    let(:menus) do
      [
        "config/editors",
        "config/proposals",
        "config/surveys",
        "config/scoped_styles",
        "config/proposal_custom_fields",
        "config/admins",
        "menus/menu/hacks",
        "menus/mobile_menu/hacks",
        "menus/home_content_block_menu/hacks",
        "custom_redirects",
        "config/livechat",
        "config/verifications",
        "maintenance/private_data",
        "maintenance/hashcash"
      ]
    end

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user

      visit decidim_admin_decidim_awesome.root_path
    end

    it "has DecidimAwesome object" do
      expect(page.body).to have_content("window.DecidimAwesome")
    end

    it "has DecidimAwesome javascript and CSS" do
      expect(page).to have_xpath("//link[@rel='stylesheet'][contains(@href,'decidim_admin_decidim_awesome')]", visible: :all)
      expect(page).to have_xpath("//script[contains(@src,'decidim_admin_decidim_awesome')]", visible: :all)
    end

    if enabled
      it "renders the editors page" do
        expect(page).to have_content("Tweaks for Editor Hacks")
      end

      it "has all admin menus" do
        menus.each do |menu|
          within ".sidebar-menu" do
            expect(page).to have_link(href: "/admin/decidim_awesome/#{menu}")
          end
        end
      end
    else
      it "renders the compatibility checks page" do
        expect(page).to have_content("Maintenance tools: System Compatibility Checks")
      end

      it "has no admin menus" do
        menus.each do |menu|
          within ".sidebar-menu" do
            expect(page).to have_no_link(href: "/admin/decidim_awesome/#{menu}")
          end
        end
      end
    end
  end
end
