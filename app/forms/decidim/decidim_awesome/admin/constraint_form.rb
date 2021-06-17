# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class ConstraintForm < Decidim::Form
        attribute :id, Integer
        attribute :participatory_space_manifest, String
        attribute :participatory_space_slug, String
        attribute :component_manifest, String
        attribute :component_id, Integer

        validates :component_manifest, absence: true, if: lambda { |form|
          form.component_id.present? || ConfigConstraintsHelpers::OTHER_MANIFESTS.include?(form.participatory_space_manifest)
        }
        validates :component_id, absence: true, if: ->(form) { form.component_manifest.present? }
      end
    end
  end
end
