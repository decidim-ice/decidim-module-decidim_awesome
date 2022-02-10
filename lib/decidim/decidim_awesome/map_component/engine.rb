# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module DecidimAwesome
    module MapComponent
      # This is the engine is used to create the component Map.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::DecidimAwesome::MapComponent

        routes do
          root to: "map#show"
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
              settings.attribute :menu_categories, type: :boolean, default: true
              settings.attribute :menu_merge_components, type: :boolean, default: true

              settings.attribute :show_not_answered, type: :boolean, default: true
              settings.attribute :show_accepted, type: :boolean, default: true
              settings.attribute :show_withdrawn, type: :boolean, default: false
              settings.attribute :show_evaluating, type: :boolean, default: true
              settings.attribute :show_rejected, type: :boolean, default: false
            end
          end
          # === TODO: processes groups map block ===
        end

        def load_seed
          nil
        end
      end
    end
  end
end
