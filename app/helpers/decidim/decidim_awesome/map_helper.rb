# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module MapHelper
      def dynamic_map_for(components)
        return if Decidim.geocoder.blank?

        map_html_options = {
          class: "google-map",
          id: "map",
          "data-components" => components.map do |component|
                                 {
                                   id: component.id,
                                   type: component.manifest.name,
                                   url: Decidim::EngineRouter.main_proxy(component).root_path
                                 }
                               end.to_json,
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
    end
  end
end
