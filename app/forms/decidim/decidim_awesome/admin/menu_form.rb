# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class MenuForm < Decidim::Form
        include Decidim::TranslatableAttributes
        VISIBILITY_STATES = %w(default hidden logged non_logged).freeze

        translatable_attribute :raw_label, String
        attribute :url, String
        attribute :position, Integer
        attribute :target, String
        attribute :visibility, String

        validates :raw_label, translatable_presence: true
        validates :url, presence: true
        validates :position, numericality: { greater_than: 0 }
        validates :visibility, inclusion: { in: VISIBILITY_STATES }

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
