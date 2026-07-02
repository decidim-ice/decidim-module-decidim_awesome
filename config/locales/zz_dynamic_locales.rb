# frozen_string_literal: true

handler = {
  decidim: {
    authorization_handlers: {
      awesome_authorization_handler: {
        name: lambda { |_key, options|
          config = Thread.current[:awesome_authorization_handler]
          options.delete(:scope)
          return I18n.t("decidim.decidim_awesome.awesome_authorization_handler.name", **options) unless config

          config&.dig("name") || I18n.t("decidim.decidim_awesome.awesome_authorization_handler.name", **options)
        },
        explanation: lambda { |_key, options|
          config = Thread.current[:awesome_authorization_handler]
          options.delete(:scope)
          return I18n.t("decidim.decidim_awesome.awesome_authorization_handler.explanation", **options) unless config

          config&.dig("explanation") || I18n.t("decidim.decidim_awesome.awesome_authorization_handler.explanation", **options)
        }
      }
    }
  }
}

Decidim.available_locales.index_with do |_locale|
  handler
end
