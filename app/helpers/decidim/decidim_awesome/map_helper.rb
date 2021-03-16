# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module MapHelper
      include Decidim::MapHelper

      def awesome_map_for(components, &block)
        return legacy_map_for(components, &block) unless defined?(Decidim::Map)

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
          "data-collapsed" => current_component.settings.collapse,
          "data-truncate" => current_component.settings.truncate,
          "data-map-center" => current_component.settings.map_center,
          "data-map-zoom" => current_component.settings.map_zoom,
          "data-menu-amendments" => current_component.settings.menu_amendments,
          "data-menu-meetings" => current_component.settings.menu_meetings,
          "data-show-not-answered" => current_component.current_settings.show_not_answered,
          "data-show-accepted" => current_component.current_settings.show_accepted,
          "data-show-withdrawn" => current_component.current_settings.show_withdrawn,
          "data-show-evaluating" => current_component.current_settings.show_evaluating,
          "data-show-rejected" => current_component.current_settings.show_rejected
        }
        content_tag(:div, map, map_html_options)
      end

      # TODO: remove when 0.22 support is diched
      def legacy_map_for(components)
        return if Decidim.geocoder.blank?

        map_html_options = {
          class: "google-map",
          id: "map",
          "data-components" => components.map do |component|
                                 {
                                   id: component.id,
                                   type: component.manifest.name,
                                   name: translated_attribute(component.name),
                                   url: Decidim::EngineRouter.main_proxy(component).root_path,
                                   amendments: component.manifest.name == :proposals ? Decidim::Proposals::Proposal.where(component: component).only_emendations.count : 0
                                 }
                               end.to_json,
          "data-collapsed" => current_component.settings.collapse,
          "data-show-not-answered" => current_component.current_settings.show_not_answered,
          "data-show-accepted" => current_component.current_settings.show_accepted,
          "data-show-withdrawn" => current_component.current_settings.show_withdrawn,
          "data-show-evaluating" => current_component.current_settings.show_evaluating,
          "data-show-rejected" => current_component.current_settings.show_rejected,
          "data-markers-data" => [].to_json
        }

        if Decidim.geocoder[:here_api_key]
          map_html_options["data-here-api-key"] = Decidim.geocoder[:here_api_key]
        else
          # Compatibility mode for old api_id/app_code configurations
          map_html_options["data-here-app-id"] = Decidim.geocoder[:here_app_id]
          map_html_options["data-here-app-code"] = Decidim.geocoder[:here_app_code]
        end

        content = capture { yield }.html_safe
        help = content_tag(:div, class: "map__help") do
          content_tag(:p, I18n.t("screen_reader_explanation", scope: "decidim.map.dynamic"), class: "show-for-sr")
        end
        content_tag :div, class: "awesome-map" do
          map = content_tag(:div, "", map_html_options)

          help + map + content
        end
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
      # rubocop:enable Rails/HelperInstanceVariable

      # rubocop:disable Naming/UncommunicativeMethodParamName
      # HSV values in [0..1[
      # returns [r, g, b] values from 0 to 255
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
      # rubocop:enable Naming/UncommunicativeMethodParamName
    end
  end
end
