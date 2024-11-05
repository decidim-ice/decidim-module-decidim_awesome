# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module MapHelper
      include Decidim::MapHelper

      def api_ready?
        Decidim::Api::Schema.max_complexity >= 1300
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity:
      def awesome_map_for(components, &block)
        return unless map_utility_dynamic

        map = awesome_builder.map_element({ class: "google-map", id: "awesome-map-container" }, &block)
        help = content_tag(:div, class: "map__help") do
          sr_content = content_tag(:p, t("screen_reader_explanation", scope: "decidim.map.dynamic"), class: "show-for-sr")

          sr_content
        end

        html_options = {
          class: "awesome-map",
          id: "awesome-map",
          data: {
            "components" => components.map do |component|
                              {
                                id: component.id,
                                type: component.manifest.name,
                                name: translated_attribute(component.name),
                                url: Decidim::EngineRouter.main_proxy(component).root_path,
                                amendments: component.manifest.name == :proposals ? Decidim::Proposals::Proposal.where(component: component).only_emendations.count : 0
                              }
                            end.to_json,
            "hide-controls" => settings_source.try(:hide_controls),
            "collapsed" => global_settings.collapse,
            "truncate" => global_settings.truncate || 255,
            "map-center" => global_settings.map_center,
            "map-zoom" => global_settings.map_zoom || 8,
            "menu-merge-components" => global_settings.menu_merge_components,
            "menu-amendments" => global_settings.menu_amendments,
            "menu-meetings" => global_settings.menu_meetings,
            "menu-categories" => global_settings.menu_categories,
            "menu-hashtags" => global_settings.menu_hashtags,
            "show-not-answered" => step_settings&.show_not_answered,
            "show-accepted" => step_settings&.show_accepted,
            "show-withdrawn" => step_settings&.show_withdrawn,
            "show-evaluating" => step_settings&.show_evaluating,
            "show-rejected" => step_settings&.show_rejected
          }
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
      def current_categories(categories)
        return @current_categories if @current_categories

        @golden_ratio_conjugate = 0.618033988749895
        # @h = rand # use random start value
        @h = 0.41
        @current_categories = []
        categories.first_class.each do |category|
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

        # We need awesome map listeners before initialize the official map
        unless snippets.any?(:awesome_map_styles) || snippets.any?(:awesome_map_scripts)
          snippets.add(:awesome_map_styles, stylesheet_pack_tag("decidim_decidim_awesome_map"))
          snippets.add(:awesome_map_scripts, javascript_pack_tag("decidim_decidim_awesome_map", defer: false))
          snippets.add(:head, snippets.for(:awesome_map_styles))
          snippets.add(DecidimAwesome.legacy_version? ? :head : :foot, snippets.for(:awesome_map_scripts))
        end

        unless snippets.any?(:map_styles) || snippets.any?(:map_scripts)
          snippets.add(:map_styles, builder.stylesheet_snippets)
          snippets.add(:map_scripts, builder.javascript_snippets)

          snippets.add(:head, snippets.for(:map_styles))
          snippets.add(DecidimAwesome.legacy_version? ? :head : :foot, snippets.for(:map_scripts))
        end

        builder
      end

      # rubocop:disable Style/FormatStringToken
      def append_category(category)
        @h += @golden_ratio_conjugate
        @h %= 1
        # r,g,b = hsv_to_rgb(@h, 0.5, 0.95)
        r, g, b = hsv_to_rgb(@h, 0.99, 0.95)
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
        f = (h * 6) - h_i
        p = v * (1 - s)
        q = v * (1 - (f * s))
        t = v * (1 - ((1 - f) * s))
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
