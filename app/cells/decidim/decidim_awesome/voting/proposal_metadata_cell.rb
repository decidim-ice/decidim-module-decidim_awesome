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
          @current_vote ||= vote_for(current_user) if current_user
        end

        def user_voted_weight
          current_vote&.weight
        end

        def all_weights
          @all_weights ||= begin
            weights = [3, 2, 1]
            weights << 0 if resource.component.settings.voting_cards_show_abstain
            weights.index_with do |weight|
              weight_count_for(weight)
            end
          end
        end

        def weight_tags
          @weight_tags ||= all_weights.map do |num, weight|
            content_tag "span", title: resource.manifest.label_for(num), class: "voting-weight_#{num}" do
              "#{t("decidim.decidim_awesome.voting.voting_cards.weights.weight_#{num}_short")} #{weight}"
            end.html_safe
          end
        end

        def weight_count_item
          # return unless resource.respond_to?(:weight_count)
          return if resource.component.current_settings.votes_hidden?
          return if resource&.rejected? || resource&.withdrawn?

          {
            text: weight_tags.join(" | ").html_safe,
            icon: "#{user_voted_weight ? "checkbox" : "close"}-circle-line",
            data_attributes: all_weights.transform_keys { |num| "weight-#{num}" }
          }
        end

        def vote_for(user)
          user_votes = memoize("user_votes")
          return user_votes[resource.id] if user_votes

          resource.votes.find_by(author: user)
        end

        def weight_count_for(weight)
          all_extra_fields = memoize("extra_fields")
          extra_fields = all_extra_fields ? all_extra_fields[resource.id] : resource.extra_fields
          return 0 unless extra_fields

          extra_fields.vote_weight_totals[weight.to_s] || 0
        end
      end
    end
  end
end
