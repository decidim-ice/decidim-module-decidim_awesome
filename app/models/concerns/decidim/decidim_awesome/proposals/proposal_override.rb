# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      module ProposalOverride
        extend ActiveSupport::Concern

        included do
          def editable_by?(user)
            return true if draft? && created_by?(user)
            return false unless default_edit_permissions(user)

            allow_to_edit_proposals_after_import ? awesome_config_allows_editing? : true
          end

          private

          def default_edit_permissions(user)
            return true if !published_state? && within_edit_time_limit? &&
                           !copied_from_other_component? && created_by?(user)

            false
          end

          def awesome_config_allows_editing?
            awesome_config = allow_to_edit_proposals_after_import

            return true if awesome_config.constraints.blank?

            constraints_to_check = manifest_to_check(awesome_config)

            participatory_space.manifest.name.to_s == constraints_to_check
          end

          def allow_to_edit_proposals_after_import
            Decidim::DecidimAwesome::AwesomeConfig.find_or_initialize_by(var: :allow_to_edit_proposals_after_import)
          end

          def manifest_to_check(awesome_config)
            constraint = awesome_config.constraints.detect { |c| c.settings["participatory_space_manifest"] }
            constraint&.settings ? constraint.settings["participatory_space_manifest"] : nil
          end
        end
      end
    end
  end
end
