# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      module OrderableOverride
        extend ActiveSupport::Concern

        included do
          before_action only: [:index] do
            session[:order] = params[:order] if params[:order].present?
          end

          private

          # read order from session if available
          def order
            @order ||= detect_order(session[:order]) || default_order
          end

          def possible_orders
            @possible_orders ||= begin
              possible_orders = %w(random recent)
              possible_orders += awesome_additional_sortings
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
            when "az"
              proposals.order(Arel.sql("decidim_proposals_proposals.title->>'#{I18n.locale}' ASC"))
            when "za"
              proposals.order(Arel.sql("decidim_proposals_proposals.title->>'#{I18n.locale}' DESC"))
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

          def awesome_additional_sortings
            return [] unless DecidimAwesome.additional_proposal_sortings.is_a?(Array)

            DecidimAwesome.additional_proposal_sortings.filter_map do |sort|
              next unless sort.to_sym.in?([:az, :za, :supported_first, :supported_last])
              next if sort.to_sym.in?([:supported_first, :supported_last]) && !supported_order_available?

              sort.to_s
            end
          end
        end
      end
    end
  end
end
