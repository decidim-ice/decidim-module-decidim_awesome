# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module LimitPendingAmendments
      extend ActiveSupport::Concern

      included do
        before_action :limit_pending_amendments, only: [:new, :create]

        def limit_pending_amendments
          byebug
        end
      end
    end
  end
end
