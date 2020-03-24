# frozen_string_literal: true

require "decidim/decidim_awesome/awesome_helpers"

module Decidim
  module DecidimAwesome
    module NeedsAwesomeConfig
      def self.extended(base)
        base.extend AwesomeHelpers
      end

      def self.included(base)
        base.include AwesomeHelpers
      end
    end
  end
end
