# frozen_string_literal: true

handler = {
  decidim: {
    authorization_handlers: {
      awesome_authorization_handler: {
        name: lambda { |_key, options|
          organization = Thread.current[:current_organization]
          options.delete(:scope)
          return I18n.t("decidim.decidim_awesome.awesome_authorization_handler.name", **options) unless organization

          config = Decidim::DecidimAwesome::AwesomeConfig.find_by(
            organization:,
            var: "decidim.decidim_awesome.awesome_authorization_handler_config"
          )
          config&.value&.dig("name") || I18n.t("decidim.decidim_awesome.awesome_authorization_handler.name", **options)
        },
        explanation: lambda { |_key, options|
          organization = Thread.current[:current_organization]
          options.delete(:scope)
          return I18n.t("decidim.decidim_awesome.awesome_authorization_handler.explanation", **options) unless organization

          config = Decidim::DecidimAwesome::AwesomeConfig.find_by(
            organization:,
            var: "decidim.decidim_awesome.awesome_authorization_handler_config"
          )
          config&.value&.dig("explanation") || I18n.t("decidim.decidim_awesome.awesome_authorization_handler.explanation", **options)
        }
      }
    }
  }
}

Decidim.available_locales.index_with do |_locale|
  handler
end
