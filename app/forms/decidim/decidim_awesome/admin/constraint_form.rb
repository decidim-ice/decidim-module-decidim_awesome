# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # A form object used to configure the endpoint.
      #
      class ConstraintForm < Decidim::Form
        attribute :id, Integer
        attribute :participatory_space_manifest, String
        attribute :participatory_space_slug, String
        attribute :component_manifest, String
      end
    end
  end
end
