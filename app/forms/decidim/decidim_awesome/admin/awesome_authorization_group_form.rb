# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class AwesomeAuthorizationGroupForm < Decidim::Form
        include Decidim::TranslatableAttributes
        translatable_attribute :name, String
        translatable_attribute :purpose, String

        validates :name, :purpose, translatable_presence: true
      end
    end
  end
end
