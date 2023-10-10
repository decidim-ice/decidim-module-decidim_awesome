# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module HasWeightCache
      extend ActiveSupport::Concern

      included do
        has_one :weight_cache, foreign_key: "decidim_proposal_id", class_name: "Decidim::DecidimAwesome::WeightCache", dependent: :destroy
      end
    end
  end
end
