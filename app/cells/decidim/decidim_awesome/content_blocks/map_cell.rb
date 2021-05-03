# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContentBlocks
      class MapCell < Decidim::ViewModel
        BUTTONS_COUNT = 5

        include Decidim::DecidimAwesome::MapHelper
        include Decidim::CardHelper
        include Decidim::NeedsSnippets

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
