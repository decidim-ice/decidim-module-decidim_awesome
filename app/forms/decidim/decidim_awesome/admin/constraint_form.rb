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
        attribute :application_context, String

        validates :component_manifest, absence: true, if: lambda { |form|
          form.component_id.present? || ConfigConstraintsHelpers::OTHER_MANIFESTS.include?(form.participatory_space_manifest&.to_sym)
        }
        validates :component_id, absence: true, if: ->(form) { form.component_manifest.present? }
        validates :application_context, inclusion: { in: ConfigConstraintsHelpers::APPLICATION_CONTEXTS.map(&:to_s) }, allow_blank: true
      end
    end
  end
end
