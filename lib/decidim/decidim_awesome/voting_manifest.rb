# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class VotingManifest
      include ActiveModel::Model
      # From 0.27 onwards, Virtus is deprecated
      if defined? Decidim::AttributeObject::Model
        include Decidim::AttributeObject::Model
      else
        include Virtus.model
      end

      attribute :name, Symbol

      # path to overriden views for the proposal show page vote button
      # not defining it will use the original view from Decidim
      # setting it to an empty string will hide the original content

      # original is decidim-proposals/app/views/proposals/proposals/_vote_button.html.erb
      attribute :show_vote_button_view, String
      # original is decidim-proposals/app/views/proposals/proposals/_votes_count.html.erb
      attribute :show_votes_count_view, String
      # original is decidim-proposals/app/cells/proposals/proposal_m/footer.erb
      attribute :proposal_m_cell_footer, String

      # a callback that will be called by the method valid_weight?
      # Do not access this parameter directly, use the weight_validator method to register a block
      attribute :on_weight_validation, Proc, default: nil

      validates :name, presence: true

      # registers a weight validator
      def weight_validator(&block)
        @on_weight_validation = block
      end

      # validates the weight using the Proc defined by weight_validator
      # Receives the weight and a context with the user and the proposal to be voted
      def valid_weight?(weight, context = {})
        return unless @on_weight_validation

        @on_weight_validation.call(weight, **context)
      end
    end
  end
end
