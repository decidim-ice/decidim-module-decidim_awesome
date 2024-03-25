# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Voting
      # This cell renders metadata for an instance of a Proposal
      class ProposalMetadataCell < ::Decidim::Proposals::ProposalMetadataCell
        private

        def proposal_items
          [coauthors_item, comments_count_item, endorsements_count_item, weight_count_item, state_item, emendation_item]
        end

        def current_vote
          @current_vote ||= Decidim::Proposals::ProposalVote.find_by(author: current_user, proposal: resource)
        end

        def user_voted_weight
          current_vote&.weight
        end

        def all_weights
          @all_weights ||= begin
            weights = [3, 2, 1]
            weights << 0 if resource.component.settings.voting_cards_show_abstain
            weights.index_with do |weight|
              resource.weight_count(weight)
            end
          end
        end

        def weight_count_item
          return unless resource.respond_to?(:weight_count)

          parts = all_weights.map do |num, weight|
            content_tag "span", title: resource.manifest.label_for(num), class: "voting-weight_#{num}" do
              "#{t("decidim.decidim_awesome.voting.voting_cards.weights.weight_#{num}_short")} #{weight}"
            end.html_safe
          end

          {
            text: parts.join(" | ").html_safe,
            icon: "#{user_voted_weight ? "checkbox" : "close"}-circle-line",
            data_attributes: all_weights.transform_keys { |num| "weight-#{num}" }
          }
        end
      end
    end
  end
end
