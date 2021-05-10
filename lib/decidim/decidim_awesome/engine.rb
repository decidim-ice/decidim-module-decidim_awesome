# frozen_string_literal: true

require "rails"
require "decidim/core"
require "decidim/decidim_awesome/awesome_helpers"

module Decidim
  module DecidimAwesome
    # This is the engine that runs on the public interface of decidim_awesome.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::DecidimAwesome

      routes do
        post :editor_images, to: "editor_images#create"
      end

      initializer "decidim_awesome.view_helpers" do
        ActionView::Base.include AwesomeHelpers
      end

      initializer "decidim_decidim_awesome.assets" do |app|
        app.config.assets.precompile += %w(decidim_decidim_awesome_manifest.js decidim_decidim_awesome_manifest.css)
        # add to precompile any present theme asset
        Dir.glob(Rails.root.join("app/assets/themes/*.*")).each do |path|
          app.config.assets.precompile << path
        end
      end

      initializer "decidim_decidim_awesome.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::DecidimAwesome::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::DecidimAwesome::Engine.root}/app/views")
      end

      initializer "decidim_decidim_awesome.content_blocks" do |_app|
        # === Map block ===
        Decidim.content_blocks.register(:homepage, :map) do |content_block|
          content_block.cell = "decidim/decidim_awesome/content_blocks/map"
          content_block.settings_form_cell = "decidim/decidim_awesome/content_blocks/map_form"
          content_block.public_name_key = "decidim.decidim_awesome.content_blocks.map.name"

          content_block.settings do |settings|
            settings.attribute :title, type: :text, translated: true
            settings.attribute :link_text, type: :text, translated: true
            settings.attribute :link_url, type: :text, translated: true

            settings.attribute :button_1_text, type: :text, translated: true
            settings.attribute :button_1_url, type: :text, translated: true
            settings.attribute :button_2_text, type: :text, translated: true
            settings.attribute :button_2_url, type: :text, translated: true
            settings.attribute :button_3_text, type: :text, translated: true
            settings.attribute :button_3_url, type: :text, translated: true
            settings.attribute :button_4_text, type: :text, translated: true
            settings.attribute :button_4_url, type: :text, translated: true
            settings.attribute :button_5_text, type: :text, translated: true
            settings.attribute :button_5_url, type: :text, translated: true

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

        # === Buttons block ===
        Decidim.content_blocks.register(:homepage, :buttons_row) do |content_block|
          content_block.cell = "decidim/decidim_awesome/content_blocks/buttons_row"
          content_block.settings_form_cell = "decidim/decidim_awesome/content_blocks/buttons_row_form"
          content_block.public_name_key = "decidim.decidim_awesome.content_blocks.buttons_row.name"

          content_block.settings do |settings|
            settings.attribute :title, type: :text, translated: true

            settings.attribute :button_1_text, type: :text, translated: true
            settings.attribute :button_1_url, type: :text, translated: true
            settings.attribute :button_2_text, type: :text, translated: true
            settings.attribute :button_2_url, type: :text, translated: true
            settings.attribute :button_3_text, type: :text, translated: true
            settings.attribute :button_3_url, type: :text, translated: true
            settings.attribute :button_4_text, type: :text, translated: true
            settings.attribute :button_4_url, type: :text, translated: true
            settings.attribute :button_5_text, type: :text, translated: true
            settings.attribute :button_5_url, type: :text, translated: true
          end
        end
      end

      # Prepare a zone to create overrides
      # https://edgeguides.rubyonrails.org/engines.html#overriding-models-and-controllers
      config.to_prepare do
        Dir.glob("#{Engine.root}/app/awesome_overrides/**/*_override.rb").each do |override|
          require_dependency override
        end
      end
    end
  end
end
