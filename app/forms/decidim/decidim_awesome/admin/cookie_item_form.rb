# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CookieItemForm < Decidim::Form
        include Decidim::TranslatableAttributes
        ITEM_TYPES = %w(cookie local_storage).freeze

        attribute :name, String
        attribute :blocked, Boolean, default: false
        attribute :type, String
        translatable_attribute :service, String
        translatable_attribute :description, String
        translatable_attribute :expiration, String

        validates :name, presence: true
        validates :name, format: {
          with: /\A[a-zA-Z0-9_\-]+\z/,
          message: :invalid_format
        }
        validates :type, inclusion: { in: ITEM_TYPES }
        validates :service, translatable_presence: true
        validates :description, translatable_presence: true
        validates :expiration, translatable_presence: true

        validate :non_editable_fields_unchanged, if: :stored_item_blocked?
        validate :validate_uniqueness, if: -> { category_items.present? }

        def non_editable_fields_unchanged
          return if category_items[name].nil?

          errors.add(:type, :readonly) unless type == (category_items[name]["type"].presence || "cookie")
          errors.add(:name, :readonly) unless name == category_items[name]["name"]
          errors.add(:expiration, :readonly) unless expiration == category_items[name]["expiration"]
        end

        def validate_uniqueness
          return if category_items[name].nil?
          return if name == context[:current_name]

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
            "type" => type.presence || "cookie",
            "edited" => true,
            "service" => service,
            "description" => description,
            "expiration" => expiration
          }
        end

        def category_items
          context[:category_items] || {}
        end

        def stored_item_blocked?
          category_items[name]&.fetch("blocked", false)
        end
      end
    end
  end
end
