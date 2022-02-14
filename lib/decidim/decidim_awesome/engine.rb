# frozen_string_literal: true

require "rails"
require "decidim/core"
require "decidim/decidim_awesome/awesome_helpers"

module Decidim
  module DecidimAwesome
    # This is the engine that runs on the public interface of decidim_awesome.
    class Engine < ::Rails::Engine
      include AwesomeHelpers

      isolate_namespace Decidim::DecidimAwesome

      routes do
        post :editor_images, to: "editor_images#create"
      end

      # Prepare a zone to create overrides
      # https://edgeguides.rubyonrails.org/engines.html#overriding-models-and-controllers
      # overrides
      config.to_prepare do
        # activate Decidim LayoutHelper for the overriden views
        ActiveSupport.on_load :action_controller do
          helper Decidim::LayoutHelper if respond_to?(:helper)
        end
        # Include additional helpers globally
        ActionView::Base.include(Decidim::DecidimAwesome::AwesomeHelpers)

        # override user's admin property
        Decidim::User.include(Decidim::DecidimAwesome::UserOverride) if DecidimAwesome.enabled?(:scoped_admins)

        # redirect unauthorized scoped admins to allowed places or custom redirects if configured
        Decidim::ErrorsController.include(Decidim::DecidimAwesome::NotFoundRedirect) if DecidimAwesome.enabled?([:scoped_admins, :custom_redirects])

        # Custom fields need to deal with several places
        if DecidimAwesome.enabled?(:proposal_custom_fields)
          Decidim::Proposals::ApplicationHelper.include(Decidim::DecidimAwesome::Proposals::ApplicationHelperOverride)
          Decidim::Proposals::ProposalWizardCreateStepForm.include(Decidim::DecidimAwesome::Proposals::ProposalWizardCreateStepFormOverride)
          Decidim::AmendmentsHelper.include(Decidim::DecidimAwesome::AmendmentsHelperOverride)
        end

        Decidim::MenuPresenter.include(Decidim::DecidimAwesome::MenuPresenterOverride)
        Decidim::MenuItemPresenter.include(Decidim::DecidimAwesome::MenuItemPresenterOverride)

        # Late registering of components to take into account initializer values
        DecidimAwesome.registered_components.each do |manifest, block|
          Decidim.register_component(manifest, &block) unless DecidimAwesome.disabled_components.include?(manifest)
        end
      end

      initializer "decidim.middleware" do |app|
        app.config.middleware.insert_after Decidim::Middleware::CurrentOrganization, Decidim::DecidimAwesome::CurrentConfig
      end

      initializer "decidim_decidim_awesome.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_decidim_awesome.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::DecidimAwesome::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::DecidimAwesome::Engine.root}/app/views")
      end
    end
  end
end
