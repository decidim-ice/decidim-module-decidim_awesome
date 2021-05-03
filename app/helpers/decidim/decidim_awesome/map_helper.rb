# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module MapHelper
      include Decidim::MapHelper

      def awesome_map_for(components, &block)
        map = dynamic_map_for({}, {}, &block)
        return unless map

        map_html_options = {
          "class" => "awesome-map",
          "id" => "awesome-map",
          "data-components" => components.map do |component|
                                 {
                                   id: component.id,
                                   type: component.manifest.name,
                                   name: translated_attribute(component.name),
                                   url: Decidim::EngineRouter.main_proxy(component).root_path,
                                   amendments: component.manifest.name == :proposals ? Decidim::Proposals::Proposal.where(component: component).only_emendations.count : 0
                                 }
                               end.to_json,
          "data-collapsed" => settings.collapse,
          "data-truncate" => settings.truncate,
          "data-map-center" => settings.map_center,
          "data-map-zoom" => settings.map_zoom,
          "data-menu-amendments" => settings.menu_amendments,
          "data-menu-meetings" => settings.menu_meetings,
          "data-menu-hashtags" => settings.menu_hashtags,
          "data-show-not-answered" => settings.show_not_answered,
          "data-show-accepted" => settings.show_accepted,
          "data-show-withdrawn" => settings.show_withdrawn,
          "data-show-evaluating" => settings.show_evaluating,
          "data-show-rejected" => settings.show_rejected
        }
        content_tag(:div, map, map_html_options)
      end

      def settings
        settings_source.try(:current_settings) || settings_source.try(:settings)
      end

      def settings_source
        try(:current_component) || try(:model)
      end

      # rubocop:disable Rails/HelperInstanceVariable
      def current_categories
        return @current_categories if @current_categories

        @golden_ratio_conjugate = 0.618033988749895
        # @h = rand # use random start value
        @h = 0.4
        @current_categories = []
        current_participatory_space.categories.first_class.each do |category|
          append_category category
          category.subcategories.each do |subcat|
            append_category subcat
          end
        end
        @current_categories
      end

      private

      # rubocop:disable Style/FormatStringToken
      def append_category(category)
        @h += @golden_ratio_conjugate
        @h %= 1
        # r,g,b = hsv_to_rgb(@h, 0.5, 0.95)
        r, g, b = hsv_to_rgb(@h, 0.99, 0.96)
        @current_categories.append(
          id: category.id,
          name: translated_attribute(category.name),
          parent: category.parent&.id,
          color: format("#%02x%02x%02x", r, g, b)
        )
      end
      # rubocop:enable Style/FormatStringToken
      # rubocop:enable Rails/HelperInstanceVariable

      # HSV values in [0..1[
      # returns [r, g, b] values from 0 to 255
      # rubocop:disable Naming/MethodParameterName
      def hsv_to_rgb(h, s, v)
        h_i = (h * 6).to_i
        f = h * 6 - h_i
        p = v * (1 - s)
        q = v * (1 - f * s)
        t = v * (1 - (1 - f) * s)
        if h_i.zero?
          r = v
          g = t
          b = p
        end
        if h_i == 1
          r = q
          g = v
          b = p
        end
        if h_i == 2
          r = p
          g = v
          b = t
        end
        if h_i == 3
          r = p
          g = q
          b = v
        end
        if h_i == 4
          r = t
          g = p
          b = v
        end
        if h_i == 5
          r = v
          g = p
          b = q
        end
        [(r * 256).to_i, (g * 256).to_i, (b * 256).to_i]
      end
    end
    # rubocop:enable Naming/MethodParameterName
  end
end
