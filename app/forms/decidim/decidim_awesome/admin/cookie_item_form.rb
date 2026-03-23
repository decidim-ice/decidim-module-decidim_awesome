# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CookieItemForm < Decidim::Form
        include Decidim::TranslatableAttributes
        ITEM_TYPES = %w(cookie local_storage).freeze

        attribute :name, String
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

        validate :non_editable_fields_unchanged, if: :blocked?
        validate :validate_uniqueness, if: -> { category_items.present? }

        def validate_uniqueness
          return if category_items[name].nil?

          errors.add(:name, :taken) if name != id
        end

        def non_editable_fields_unchanged
          errors.add(:type, :invalid) unless type == current_item["type"]
          errors.add(:name, :invalid) unless name == current_item["name"]
          errors.add(:expiration, :invalid) unless expiration == current_item["expiration"]
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

        def category
          context[:category] || {}
        end

        def id
          context[:id]
        end

        def category_items
          category["items"] || {}
        end

        def current_item
          category_items[id]
        end

        def blocked?
          current_item && category["default"] && current_item["default"]
        end
      end
    end
  end
end
