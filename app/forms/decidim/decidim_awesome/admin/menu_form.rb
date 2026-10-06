# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class MenuForm < Decidim::Form
        include Decidim::TranslatableAttributes

        VISIBILITY_STATES = %w(default hidden logged non_logged verified_user).freeze

        translatable_attribute :raw_label, String
        attribute :url, String
        attribute :position, Integer
        attribute :target, String
        attribute :visibility, String

        validates :raw_label, translatable_presence: true
        validates :url, presence: true
        validates :position, numericality: { greater_than: 0 }
        validates :visibility, inclusion: { in: VISIBILITY_STATES }
        validates :target, inclusion: { in: ["", "_blank"] }

        # remove query string from native menu element (to avoid interactions with the locale in the generated url)
        def map_model(model)
          self.url = ContextAnalyzers::RequestAnalyzer.strip_locale(Addressable::URI.parse(model.url).path) if model.native?
        end

        def to_params
          {
            label: raw_label,
            position:,
            url: normalized_url,
            target:,
            visibility:
          }
        end

        # Stored urls carry neither the organization host nor a locale prefix, the locale is added when rendering
        def normalized_url
          ContextAnalyzers::RequestAnalyzer.strip_locale(local_path)
        end

        private

        def local_path
          parsed = Addressable::URI.parse(url.to_s.strip)
          parsed.host.present? && parsed.host == current_organization&.host ? parsed.request_uri : url.to_s.strip
        end
      end
    end
  end
end
