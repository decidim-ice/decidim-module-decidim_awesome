# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class MenuForm < Decidim::Form
        include Decidim::TranslatableAttributes

        translatable_attribute :label, String
        attribute :url, String
        attribute :position, Integer
        attribute :target, String
        attribute :visible, Boolean

        validates :label, translatable_presence: true
        validates :url, presence: true
        validates :position, numericality: { greater_than: 0 }

        def to_params
          {
            label: label,
            position: position,
            url: url
            #  target: target,
            #  visible: visible
          }
        end
      end
    end
  end
end
