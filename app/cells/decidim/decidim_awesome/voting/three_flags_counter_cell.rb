# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Voting
      class ThreeFlagsCounterCell < ThreeFlagsBaseCell
        COLORS = { 1 => "alert", 2 => "warning", 3 => "success" }.freeze
        BUTTON_CLASSES = { 0 => "hollow", 1 => "danger", 2 => "warning", 3 => "success" }.freeze

        def show
          render :show
        end

        def resource_path
          resource_locator(model).path
        end

        def user_voted_weight
          current_vote&.weight
        end

        def vote_btn_class
          BUTTON_CLASSES[user_voted_weight.to_i]
        end
      end
    end
  end
end
