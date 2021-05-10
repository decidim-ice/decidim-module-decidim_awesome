# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContentBlocks
      class ButtonsRowCell < Decidim::ViewModel
        BUTTONS_COUNT = 5

        def section_title
          translated_attribute(model.settings.title)
        end

        def buttons
          safe_join(
            1.upto(BUTTONS_COUNT).map do |x|
              next unless translated_attribute(model.settings.send(:"button_#{x}_text"))

              link_to translated_attribute(model.settings.send(:"button_#{x}_text")), translated_attribute(model.settings.send(:"button_#{x}_url")), class: "button button--sc expanded"
            end.compact
          )
        end
      end
    end
  end
end
