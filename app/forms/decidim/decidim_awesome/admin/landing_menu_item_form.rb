# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class LandingMenuItemForm < Decidim::Form
        include Decidim::TranslatableAttributes

        translatable_attribute :name, String
        attribute :url, String
        attribute :visible, Decidim::AttributeObject::Model::Boolean, default: true

        validates :url, format: { with: MenuItemsParser::SAFE_URL_PATTERN }, allow_blank: true
      end
    end
  end
end
