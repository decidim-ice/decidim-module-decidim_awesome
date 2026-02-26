# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CookieCategoryForm < Decidim::Form
        include Decidim::TranslatableAttributes
        VISIBILITY_STATES = %w(default hidden logged non_logged verified_user).freeze

        attribute :slug, String
        attribute :mandatory, Boolean
        translatable_attribute :title, String
        translatable_attribute :description, String
        attribute :visibility, String

        validates :slug, presence: true
        validates :slug, format: { with: /\A[a-z0-9-]+\z/ }
        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :visibility, inclusion: { in: VISIBILITY_STATES }

        def to_params
          {
            "slug" => slug,
            "mandatory" => mandatory || false,
            "title" => title,
            "description" => description,
            "items" => [],
            "visibility" => visibility
          }
        end
      end
    end
  end
end
