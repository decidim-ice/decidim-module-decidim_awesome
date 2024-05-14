# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContentBlocks
      class MapCell < Decidim::ViewModel
        include Cell::ViewModel::Partial
        include Decidim::DecidimAwesome::MapHelper
        include Decidim::CardHelper

        delegate :snippets, to: :controller
        delegate :settings, to: :model
        alias current_settings settings

        def show
          return error unless Decidim::Map.configured?

          render
        end

        def error
          render
        end

        def hide_controls
          true
        end

        def all_categories
          return if @all_categories.present?

          @category_ids ||= Decidim::Category.pluck(:id, :decidim_participatory_space_type, :decidim_participatory_space_id).select do |category|
            _id, space_type, space_id = category
            space = space_type.constantize.find(space_id)
            space.organization == current_organization
          end.map(&:first)

          @all_categories ||= Decidim::Category.where(id: @category_ids)
        end

        def global_map_components
          @global_map_components ||= Decidim::Component.where(manifest_name: [:meetings, :proposals]).published.filter do |component|
            if component.organization == current_organization
              case component.manifest.name
              when :meetings
                true
              when :proposals
                component.settings.geocoding_enabled
              else
                false
              end
            else
              false
            end
          end
        end

        def section_title
          return if model.settings.title.blank?
          return if model.settings.title.values.join.blank?

          content_tag :h3, class: "section-heading" do
            translated_attribute(model.settings.title)
          end
        end
      end
    end
  end
end
