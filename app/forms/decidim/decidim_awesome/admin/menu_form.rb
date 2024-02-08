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
          self.url = Addressable::URI.parse(model.url).path if model.native?
        end

        def to_params
          {
            label: raw_label,
            position:,
            url:,
            target:,
            visibility:
          }
        end
      end
    end
  end
end
