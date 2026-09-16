# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      module OrderableOverride
        extend ActiveSupport::Concern
        include Decidim::DecidimAwesome::NeedsAwesomeConfig

        included do
          before_action only: [:index] do
            session[:order] = params[:order] if params[:order].present?
          end

          private

          alias_method :decidim_original_reorder, :reorder

          # read order from session if available
          def order
            @order ||= detect_order(session[:order]) || default_order
          end

          def possible_orders
            @possible_orders ||= begin
              possible_orders = %w(random recent)
              possible_orders += awesome_additional_sortings
              possible_orders << "most_voted" if most_voted_order_available?
              possible_orders << "most_liked" if current_settings.likes_enabled?
              possible_orders << "most_commented" if component_settings.comments_enabled?
              possible_orders << "most_followed" << "with_more_authors"
              possible_orders
            end
          end

          def reorder(proposals)
            order_by_title = Arel.sql(%{COALESCE(decidim_proposals_proposals.title->>'#{locale}', decidim_proposals_proposals.title->'machine_translations'->>'#{locale}', decidim_proposals_proposals.title->>'#{default_locale}', (SELECT value FROM jsonb_each_text(decidim_proposals_proposals.title) WHERE key <> 'machine_translations' ORDER BY key LIMIT 1))  #{collation}})
            case order
            when "az"
              proposals.order(order_by_title => :asc)
            when "za"
              proposals.order(order_by_title => :desc)
            when "supported_first"
              proposals.joins(my_votes_join).group(:id).order(Arel.sql("COUNT(decidim_proposals_proposal_votes.id) DESC"))
            when "supported_last"
              proposals.joins(my_votes_join).group(:id).order(Arel.sql("COUNT(decidim_proposals_proposal_votes.id) ASC"))
            else
              decidim_original_reorder(proposals)
            end
          end

          def collation
            @collation ||= begin
              collation = Decidim::DecidimAwesome.collation_for(locale)
              "COLLATE \"#{collation}\"" if collation.present?
            end
          end

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
            return [] unless DecidimAwesome.enabled?(:additional_proposal_sortings)
            return [] if awesome_config[:additional_proposal_sortings].blank?
            return [] unless awesome_config_instance.constrained_in_context?(:additional_proposal_sortings)

            awesome_config[:additional_proposal_sortings].filter_map do |sort|
              sort = sort.to_s
              next unless sort.in? DecidimAwesome.possible_additional_proposal_sortings
              next if sort.in?(%w(supported_first supported_last)) && !supported_order_available?

              sort
            end
          end
        end
      end
    end
  end
end
