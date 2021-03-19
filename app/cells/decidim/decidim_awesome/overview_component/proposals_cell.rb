# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module OverviewComponent
      # This cell renders the Medium (:m) overview card
      # for an given instance of a Component
      class ProposalsCell < OverviewMCell
        def items
          Decidim::Proposals::Proposal.where(component: model)
        end

        def description
          render :description
        end

        def date
          model.participatory_space.active_step.end_date
        end

        private
  
        def has_children?
          true
        end

        def has_state?
          true
        end

        def state_classes
          if remaining_votes.positive?
            ["alert"]
          else
            ["muted"]
          end
        end

        def resource_path
          Decidim::EngineRouter.main_proxy(model).proposals_path
        end

        def statuses
          [:end_date] + super
        end
  
        def end_date_status
          explanation = tag.strong(t("#{i18n_scope}.date"))
          "#{explanation}<br>#{l(date, format: :decidim_short)}"
        end

        def show_progress?
          return unless current_user
          has_vote_limit?
        end
        
        def needs_participation?
          return unless current_user
          has_vote_limit? ? remaining_votes.positive? : true
        end

        def has_vote_limit?
          model.settings.vote_limit.positive?
        end

        def remaining_votes
          model.settings.vote_limit - consumed_votes
        end
        
        def consumed_votes
          Decidim::Proposals::ProposalVote.where(proposal: items, author: current_user).count
        end

        def progress_bar_progress
          consumed_votes
        end
        
        def progress_bar_total
          model.settings.vote_limit || 0
        end

        def progress_bar_subtitle_text
          t("#{i18n_scope}.progress_subtitle")
        end
      end
    end
  end
end
