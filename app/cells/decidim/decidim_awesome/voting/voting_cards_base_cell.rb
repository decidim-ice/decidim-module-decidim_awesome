# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Voting
      class VotingCardsBaseCell < Decidim::ViewModel
        include Decidim::IconHelper
        include Decidim::ComponentPathHelper
        include Decidim::Proposals::ProposalVotesHelper
        include Decidim::Proposals::Engine.routes.url_helpers

        delegate :current_settings, to: :current_component

        def proposal
          model
        end

        def sanitized_title
          strip_tags(translated_attribute(proposal.title))
        end

        def current_component
          proposal.component
        end

        def component_settings
          current_component.settings
        end

        def current_vote
          @current_vote ||= vote_for(current_user) if current_user
        end

        def user_voted_weight
          current_vote&.weight
        end

        def vote_for(user)
          user_votes = memoize("user_votes")
          return user_votes[model.id] if user_votes

          model.votes.find_by(author: user)
        end

        def weight_count_for(weight)
          all_extra_fields = memoize("extra_fields")
          extra_fields = all_extra_fields ? all_extra_fields[model.id] : model.extra_fields
          return 0 unless extra_fields

          extra_fields.vote_weight_totals[weight.to_s] || 0
        end
      end
    end
  end
end
