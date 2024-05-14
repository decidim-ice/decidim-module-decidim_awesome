# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ProposalTypeOverride
      extend ActiveSupport::Concern

      included do
        field :vote_weights, GraphQL::Types::JSON, description: "The corresponding weights count to the proposal votes", null: true

        def vote_weights
          current_component = object.component
          object.vote_weights unless current_component.current_settings.votes_hidden?
        end
      end
    end
  end
end
