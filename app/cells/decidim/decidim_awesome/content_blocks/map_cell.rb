# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContentBlocks
      class MapCell < Decidim::ViewModel
        BUTTONS_COUNT = 5

        include Decidim::DecidimAwesome::MapHelper
        include Decidim::CardHelper

        delegate :snippets, to: :controller

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
          @global_map_components ||= Decidim::Component.where(manifest_name: "meetings").published
        end

        def section_title
          translated_attribute(model.settings.title)
        end

        def buttons_data
          1.upto(BUTTONS_COUNT).map do |x|
            data = %w(text url).map { |field| translated_attribute(model.settings.send(:"button_#{x}_#{field}")) }
            data unless data.any?(&:blank?)
          end.compact
        end

        def buttons
          safe_join(
            buttons_data.map { |button| link_to button.first, button.last, class: "button button--sc expanded" }
          )
        end
      end
    end
  end
end
