# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Voting
      class VotingCardsProposalCell < VotingCardsBaseCell
        VOTE_WEIGHTS = [0, 1, 2, 3].freeze

        def show
          render :show
        end

        def vote_block_for(proposal, weight)
          render partial: "vote_block", locals: {
            proposal:,
            weight:
          }
        end

        def vote_instructions
          translated_attribute(current_component.settings.voting_cards_instructions).presence ||
            t("decidim.decidim_awesome.voting.voting_cards.default_instructions_html", organization: translated_attribute(current_organization.name))
        end

        def proposal_votes(weight)
          model.weight_count(weight)
        end

        def voted_for?(option)
          user_voted_weight == option
        end

        def from_proposals_list
          options[:from_proposals_list]
        end

        def proposal_vote_path(weight)
          proposal_proposal_vote_path(proposal_id: proposal.id, from_proposals_list:, weight:)
        end

        def link_options(weight)
          ops = {
            class: "vote-action vote-card #{classes_for(weight)}"
          }
          if current_user
            ops.merge!({
                         remote: true,
                         method: :post
                       })
          end
          ops
        end

        def svg_path(weight)
          card = "handcard"
          card = "handcheck" if voted_for?(weight)
          "#{asset_pack_path("media/images/#{card}.svg")}#handcard"
        end

        def classes_for(weight)
          ops = ["weight_#{weight}"]
          ops << "voted" if voted_for?(weight)
          ops << "dim" if voted_for_any? && !voted_for?(weight)
          ops << "disabled" if disabled?

          ops.join(" ")
        end

        def disabled?
          return true if voted_for_any? || current_settings.votes_blocked?

          if proposal.maximum_votes_reached? && !proposal.can_accumulate_votes_beyond_threshold && current_component.participatory_space.can_participate?(current_user)
            return true
          end

          true if vote_limit_enabled? && remaining_votes_count_for(current_user) <= 0
        end

        def voted_for_any?
          VOTE_WEIGHTS.any? { |opt| voted_for?(opt) }
        end

        def title
          txt ||= translated_attribute(current_component.settings.voting_cards_box_title)
          return "" if txt == "-"

          txt.presence || t("decidim.decidim_awesome.voting.voting_cards.default_box_title")
        end
      end
    end
  end
end
