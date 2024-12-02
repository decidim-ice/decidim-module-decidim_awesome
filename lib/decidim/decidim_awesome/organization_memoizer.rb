# frozen_string_literal: true

module Decidim
  # add a global helper with awesome configuration
  module DecidimAwesome
    module OrganizationMemoizer
      def self.memoize(key)
        @memoized ||= {}
        @memoized[key] ||= yield
      end

      # memoize a piece of code in the class instead of the instance (helper are initialized for each view)
      # only works if request.env["decidim.current_organization"] is defined
      def memoize(key, &block)
        return yield unless request.env["decidim.current_organization"]&.id

        OrganizationMemoizer.memoize("#{request.env["decidim.current_organization"].id}-#{key}", &block)
      end
    end
  end
end
