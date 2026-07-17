# frozen_string_literal: true

Decidim.available_locales.index_with do |locale|
  {
    decidim: {
      authorization_handlers: {
        awesome_authorization_handler: {
          name: lambda { |_key, options|
            config = Thread.current[:awesome_authorization_handler]
            options.delete(:scope)
            return I18n.t("decidim.decidim_awesome.awesome_authorization_handler.name", **options) unless config.is_a?(Hash)

            config.dig("name", locale).presence || I18n.t("decidim.decidim_awesome.awesome_authorization_handler.name", **options)
          },
          explanation: lambda { |_key, options|
            config = Thread.current[:awesome_authorization_handler]
            options.delete(:scope)
            return I18n.t("decidim.decidim_awesome.awesome_authorization_handler.explanation", **options) unless config.is_a?(Hash)

            config.dig("explanation", locale).presence || I18n.t("decidim.decidim_awesome.awesome_authorization_handler.explanation", **options)
          }
        }
      }
    }
  }
end
