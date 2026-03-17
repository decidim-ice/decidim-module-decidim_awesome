# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CookieCategoryForm < Decidim::Form
        include Decidim::TranslatableAttributes
        VISIBILITY_STATES = %w(visible hidden).freeze

        attribute :slug, String
        attribute :editable, Boolean, default: true
        attribute :mandatory, Boolean
        translatable_attribute :title, String
        translatable_attribute :description, String
        attribute :visibility, String

        validates :slug, presence: true
        validates :slug, format: { with: /\A[a-z0-9-]+\z/ }
        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :visibility, inclusion: { in: VISIBILITY_STATES }, if: -> { visibility.present? }

        validate :non_editable_fields_unchanged, unless: :editable?
        validate :validate_uniqueness, if: -> { categories.present? }

        def non_editable_fields_unchanged
          # todo
        end

        def validate_uniqueness
          return if categories[slug].nil?

          errors.add(:slug, :taken)
        end

        def visibility_options
          VISIBILITY_STATES.index_by { |state| I18n.t(".cookie_categories.form.visibility.#{state}", scope: "decidim.decidim_awesome.admin") }
        end

        def to_params
          {
            "title" => title,
            "edited" => true,
            "description" => description,
            "visibility" => visibility || "visible",
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
