# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ProposalLCellOverride
      extend ActiveSupport::Concern

      included do
        private

        def metadata_cell
          awesome_voting_manifest_for(resource&.component)&.proposal_metadata_cell.presence || "decidim/proposals/proposal_metadata"
        end

        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable Metrics/PerceivedComplexity
        def cache_hash
          hash = []
          hash << I18n.locale.to_s
          hash << model.cache_key_with_version
          hash << model.proposal_votes_count
          hash << model.extra_fields&.reload&.vote_weight_totals
          hash << model.endorsements_count
          hash << model.comments_count
          hash << Digest::MD5.hexdigest(model.component.cache_key_with_version)
          hash << Digest::MD5.hexdigest(resource_image_path) if resource_image_path
          hash << render_space? ? 1 : 0
          if current_user
            hash << current_user.cache_key_with_version
            hash << current_user.follows?(model) ? 1 : 0
          end
          hash << model.follows_count
          hash << Digest::MD5.hexdigest(model.authors.map(&:cache_key_with_version).to_s)
          hash << (model.must_render_translation?(model.organization) ? 1 : 0) if model.respond_to?(:must_render_translation?)
          hash << model.component.participatory_space.active_step.id if model.component.participatory_space.try(:active_step)

          hash.join(Decidim.cache_key_separator)
        end
        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/PerceivedComplexity
      end
    end
  end
end
