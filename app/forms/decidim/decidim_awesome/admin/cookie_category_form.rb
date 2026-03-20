# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CookieCategoryForm < Decidim::Form
        include Decidim::TranslatableAttributes
        VISIBILITY_STATES = %w(visible hidden).freeze

        attribute :slug, String
        attribute :blocked, Boolean, default: false
        attribute :mandatory, Boolean
        translatable_attribute :title, String
        translatable_attribute :description, String
        attribute :visibility, String, default: "visible"

        validates :slug, presence: true
        validates :slug, format: { with: /\A[a-z0-9-]+\z/ }
        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :visibility, inclusion: { in: VISIBILITY_STATES }, if: -> { visibility.present? }

        validate :non_editable_fields_unchanged, if: :blocked?
        validate :validate_uniqueness, if: -> { categories.present? }

        def non_editable_fields_unchanged
          errors.add(:mandatory, :readonly) unless mandatory
          errors.add(:visibility, :readonly) unless visibility == "visible"
        end

        def validate_uniqueness
          return if categories[slug].nil?

          errors.add(:slug, :taken)
        end

        def visibility_options
          VISIBILITY_STATES.index_by { |state| I18n.t("cookie_categories.form.visibility.#{state}", scope: "decidim.decidim_awesome.admin") }
        end

        def to_params
          {
            "title" => title,
            "slug" => slug,
            "edited" => true,
            "description" => description,
            "visibility" => visibility,
            "mandatory" => mandatory
          }
        end

        def categories
          context[:categories] || {}
        end
      end
    end
  end
end
