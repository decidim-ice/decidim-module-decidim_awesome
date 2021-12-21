# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module MapHelper
      include Decidim::MapHelper

      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity:
      def awesome_map_for(components, &block)
        return unless map_utility_dynamic

        map = awesome_builder.map_element({ class: "google-map" }, &block)
        help = content_tag(:div, class: "map__help") do
          sr_content = content_tag(:p, t("screen_reader_explanation", scope: "decidim.map.dynamic"), class: "show-for-sr")

          sr_content
        end

        html_options = {
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
          "data-hide-controls" => settings_source.try(:hide_controls),
          "data-collapsed" => global_settings.collapse,
          "data-truncate" => global_settings.truncate || 255,
          "data-map-center" => global_settings.map_center,
          "data-map-zoom" => global_settings.map_zoom || 8,
          "data-menu-amendments" => global_settings.menu_amendments,
          "data-menu-meetings" => global_settings.menu_meetings,
          "data-menu-hashtags" => global_settings.menu_hashtags,
          "data-show-not-answered" => step_settings&.show_not_answered,
          "data-show-accepted" => step_settings&.show_accepted,
          "data-show-withdrawn" => step_settings&.show_withdrawn,
          "data-show-evaluating" => step_settings&.show_evaluating,
          "data-show-rejected" => step_settings&.show_rejected
        }

        content_tag(:div, html_options) do
          content_tag :div, class: "row column" do
            help + map
          end
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity:

      def step_settings
        settings_source.try(:current_settings)
      end

      def global_settings
        settings_source.try(:settings)
      end

      def settings_source
        try(:current_component) || self
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

      def awesome_builder
        options = {
          popup_template_id: "marker-popup",
          markers: []
        }
        builder = map_utility_dynamic.create_builder(self, options)

        unless snippets.any?(:map)
          snippets.add(:map, builder.stylesheet_snippets)
          snippets.add(:map, builder.javascript_snippets)
          snippets.add(:head, snippets.for(:map))
        end

        unless snippets.any?(:awesome_map)
          snippets.add(:awesome_map, javascript_pack_tag("decidim_decidim_awesome_map"))
          snippets.add(:awesome_map, javascript_pack_tag("decidim_decidim_awesome_load_map"))
          snippets.add(:awesome_map, stylesheet_pack_tag("decidim_decidim_awesome_map"))
          snippets.add(:head, snippets.for(:awesome_map))
        end

        builder
      end

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
