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
            id, space_type, space_id = category
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

        def buttons
          safe_join(
            1.upto(BUTTONS_COUNT).map do |x|
              next unless translated_attribute(model.settings.send(:"button_#{x}_text"))

              link_to translated_attribute(model.settings.send(:"button_#{x}_text")), translated_attribute(model.settings.send(:"button_#{x}_url"))
            end.compact
          )
        end
      end
    end
  end
end
