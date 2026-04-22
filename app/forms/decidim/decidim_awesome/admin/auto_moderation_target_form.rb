# frozen_string_literal: true

module Decidim
    module DecidimAwesome
        module Admin
            class AutoModerationTargetForm < Decidim::Form
                attribute :object_type, String
                attribute :action_type, String
                attribute :action_options, Hash, default: "{}"
                attribute :hits, Integer, default: 0

                validates :object_type, presence: true
                validates :action_type, presence: true
                validates :action_type, inclusion: { in: Decidim::DecidimAwesome.moderation_actions_registry.manifests.map(&:name).map(&:to_s) }, if: -> { action_type.present? }
                validates :object_type, inclusion: { in: [Decidim::Proposals::Proposal.model_name.element, Decidim::Comments::Comment.model_name.element] }, if: -> { object_type.present? }

                def to_params
                    {
                        "object_type" => object_type,
                        "action_type" => action_type,
                        "action_options" => action_options,
                        "hits" => hits
                    }
                end
            end
        end
    end
end