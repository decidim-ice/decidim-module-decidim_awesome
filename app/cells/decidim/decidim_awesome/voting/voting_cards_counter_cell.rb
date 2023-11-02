# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Voting
      class VotingCardsCounterCell < VotingCardsBaseCell
        def show
          render :show
        end

        def resource_path
          resource_locator(model).path
        end

        def vote_btn_class
          user_voted_weight ? "weight_#{user_voted_weight.to_i}" : "hollow"
        end
      end
    end
  end
end
