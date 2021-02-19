# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class MenuForm < Decidim::Form
        include Decidim::TranslatableAttributes

        translatable_attribute :raw_label, String
        attribute :url, String
        attribute :position, Integer
        attribute :target, String
        attribute :visibility, Boolean

        validates :raw_label, translatable_presence: true
        validates :url, presence: true
        validates :position, numericality: { greater_than: 0 }

        def to_params
          {
            label: raw_label,
            position: position,
            url: url,
            target: target,
            visibility: visibility
          }
        end
      end
    end
  end
end
