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
        attribute :component_id, Integer

        validates :component_manifest, absence: true, if: ->(form) { form.component_id.present? || form.participatory_space_manifest == "system" }
        validates :component_id, absence: true, if: ->(form) { form.component_manifest.present? }
      end
    end
  end
end
