# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContentBlocks
      class ButtonsRowCell < Decidim::ViewModel
        BUTTONS_COUNT = 5

        def show
          render if section_title.present? && buttons.present?
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
