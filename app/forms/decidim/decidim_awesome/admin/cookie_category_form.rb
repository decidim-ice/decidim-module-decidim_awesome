# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CookieCategoryForm < Decidim::Form
        include Decidim::TranslatableAttributes

        attribute :slug, String
        attribute :mandatory, Boolean
        translatable_attribute :title, String
        translatable_attribute :description, String

        validates :slug, presence: true
        validates :slug, format: { with: /\A[a-z0-9-]+\z/ }
        validates :title, translatable_presence: true
        validates :description, translatable_presence: true

        def to_params
          {
            "slug" => slug,
            "mandatory" => mandatory || false,
            "title" => title,
            "description" => description,
            "items" => []
          }
        end
      end
    end
  end
end
