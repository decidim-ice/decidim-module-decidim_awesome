# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      module OrderableOverride
        extend ActiveSupport::Concern

        included do
          private

          def possible_orders
            @possible_orders ||= begin
              possible_orders = %w(random recent)
              possible_orders << "supported_first" if supported_order_available?
              possible_orders << "supported_last" if supported_order_available?
              possible_orders << "most_voted" if most_voted_order_available?
              possible_orders << "most_endorsed" if current_settings.endorsements_enabled?
              possible_orders << "most_commented" if component_settings.comments_enabled?
              possible_orders << "most_followed" << "with_more_authors"
              possible_orders
            end
          end

          # rubocop:disable Metrics/CyclomaticComplexity
          def reorder(proposals)
            case order
            when "supported_first"
              proposals.joins(my_votes_join).group(:id).order(Arel.sql("COUNT(decidim_proposals_proposal_votes.id) DESC"))
            when "supported_last"
              proposals.joins(my_votes_join).group(:id).order(Arel.sql("COUNT(decidim_proposals_proposal_votes.id) ASC"))
            when "most_commented"
              proposals.left_joins(:comments).group(:id).order(Arel.sql("COUNT(decidim_comments_comments.id) DESC"))
            when "most_endorsed"
              proposals.order(endorsements_count: :desc)
            when "most_followed"
              proposals.left_joins(:follows).group(:id).order(Arel.sql("COUNT(decidim_follows.id) DESC"))
            when "most_voted"
              proposals.order(proposal_votes_count: :desc)
            when "random"
              proposals.order_randomly(random_seed)
            when "recent"
              proposals.order(published_at: :desc)
            when "with_more_authors"
              proposals.order(coauthorships_count: :desc)
            end
          end
          # rubocop:enable Metrics/CyclomaticComplexity

          def my_votes_join
            votes_table = Decidim::Proposals::ProposalVote.arel_table
            proposals_table = Decidim::Proposals::Proposal.arel_table
            Arel::Nodes::OuterJoin.new(
              votes_table,
              Arel::Nodes::On.new(
                votes_table[:decidim_proposal_id].eq(proposals_table[:id])
                  .and(votes_table[:decidim_author_id].eq(current_user.id))
              )
            )
          end

          def supported_order_available?
            most_voted_order_available? && current_user
          end
        end
      end
    end
  end
end
