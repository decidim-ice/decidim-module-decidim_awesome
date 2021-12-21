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

      initializer "decidim.middleware" do |app|
        app.config.middleware.insert_after Decidim::Middleware::CurrentOrganization, Decidim::DecidimAwesome::CurrentConfig
      end

      # Prepare a zone to create overrides
      # https://edgeguides.rubyonrails.org/engines.html#overriding-models-and-controllers
      # overrides
      config.to_prepare do
        ActiveSupport.on_load :action_controller do
          helper Decidim::LayoutHelper if respond_to?(:helper)
        end

        if DecidimAwesome.config[:scoped_admins] != :disabled
          # override user's admin property
          Decidim::User.include(UserOverride)
          # redirect unauthorized scoped admins to allowed places
          Decidim::ErrorsController.include(AdminNotFoundRedirect)
        end

        Decidim::Proposals::ApplicationHelper.include(Decidim::DecidimAwesome::Proposals::ApplicationHelperOverride)
        Decidim::AmendmentsHelper.include(Decidim::DecidimAwesome::AmendmentsHelperOverride)

        # TODO: move to include overrides
        Dir.glob("#{Engine.root}/app/awesome_overrides/**/*_override.rb").each do |override|
          require_dependency override
        end
      end

      initializer "decidim_awesome.view_helpers" do
        config.to_prepare do
          ActionView::Base.include AwesomeHelpers
        end
      end

      initializer "decidim_decidim_awesome.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_decidim_awesome.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::DecidimAwesome::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::DecidimAwesome::Engine.root}/app/views")
      end

      initializer "decidim_decidim_awesome.content_blocks" do |_app|
        # === Home Map block ===
        Decidim.content_blocks.register(:homepage, :awesome_map) do |content_block|
          content_block.cell = "decidim/decidim_awesome/content_blocks/map"
          content_block.settings_form_cell = "decidim/decidim_awesome/content_blocks/map_form"
          content_block.public_name_key = "decidim.decidim_awesome.content_blocks.map.name"

          content_block.settings do |settings|
            settings.attribute :title, type: :text, translated: true

            settings.attribute :map_height, type: :integer, default: 500
            settings.attribute :map_center, type: :string, default: ""
            settings.attribute :map_zoom, type: :integer, default: 8
            settings.attribute :truncate, type: :integer, default: 255
            settings.attribute :collapse, type: :boolean, default: false
            settings.attribute :menu_amendments, type: :boolean, default: true
            settings.attribute :menu_meetings, type: :boolean, default: true
            settings.attribute :menu_hashtags, type: :boolean, default: true

            settings.attribute :show_not_answered, type: :boolean, default: true
            settings.attribute :show_accepted, type: :boolean, default: true
            settings.attribute :show_withdrawn, type: :boolean, default: false
            settings.attribute :show_evaluating, type: :boolean, default: true
            settings.attribute :show_rejected, type: :boolean, default: false
          end
        end
        # === TODO: processes groups map block ===
      end
    end
  end
end
