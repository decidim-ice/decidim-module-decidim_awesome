# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      module ProposalOverride
        extend ActiveSupport::Concern

        included do
          def editable_by?(user)
            return true if draft? && created_by?(user)

            if allow_to_edit_proposals_after_import.value && copied_from_other_component?
              can_edit_copied_component?(user)
            else
              default_edit_permissions(user)
            end
          end

          private

          def can_edit_copied_component?(user)
            return false unless within_edit_time_limit? && created_by?(user)

            awesome_config_allows_editing?
          end

          def default_edit_permissions(user)
            !published_state? && within_edit_time_limit? && !copied_from_other_component? && created_by?(user)
          end

          def awesome_config_allows_editing?
            return true if allow_to_edit_proposals_after_import.constraints.blank?

            allow_to_edit_proposals_after_import.constraints.any? do |constraint|
              check_constraint(constraint)
            end
          end

          def allow_to_edit_proposals_after_import
            Decidim::DecidimAwesome::AwesomeConfig.find_or_initialize_by(var: :allow_to_edit_proposals_after_import)
          end

          def check_constraint(constraint)
            constraint.settings.all? do |key, value|
              case key
              when "participatory_space_manifest"
                value == participatory_space.manifest.name.to_s
              when "participatory_space_slug"
                value == participatory_space.slug
              when "component_manifest"
                value == component.manifest.name.to_s
              when "component_id"
                value == component.id
              else
                false
              end
            end
          end
        end
      end
    end
  end
end
