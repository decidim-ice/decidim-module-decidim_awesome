# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # Sanitizes proposal bodies written by participants with the admin rules, without the extra tags reserved to admins.
    class ProposalBodyScrubber < Decidim::AdminInputScrubber
      private

      def extra_allowed_tags
        []
      end
    end
  end
end
