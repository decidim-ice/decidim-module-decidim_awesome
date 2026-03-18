# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CookieItemForm < Decidim::Form
        include Decidim::TranslatableAttributes
        ITEM_TYPES = %w(cookie local_storage).freeze

        attribute :name, String
        attribute :editable, Boolean, default: true
        attribute :type, String
        translatable_attribute :service, String
        translatable_attribute :description, String
        translatable_attribute :expiration, String

        validates :name, presence: true
        validates :name, format: {
          with: %r{\A[a-zA-Z0-9_.:\-/]+\z},
          message: :invalid_format
        }
        validates :type, inclusion: { in: ITEM_TYPES }
        validates :service, translatable_presence: true
        validates :description, translatable_presence: true
        validates :expiration, translatable_presence: true

        validate :non_editable_fields_unchanged, unless: :editable?
        validate :validate_uniqueness, if: -> { category_items.present? }

        def non_editable_fields_unchanged
          # todo
        end

        def validate_uniqueness
          return if category_items[name].nil?

          errors.add(:name, :taken)
        end

        def item_type_options
          ITEM_TYPES.index_by do |type|
            I18n.t("cookie_item.types.#{type}", scope: "activemodel.attributes")
          end
        end

        def to_params
          {
            "name" => name,
            "edited" => true,
            "type" => type.presence || "cookie",
            "service" => service,
            "description" => description,
            "expiration" => expiration
          }
        end

        def category_items
          context[:category_items] || {}
        end
      end
    end
  end
end
