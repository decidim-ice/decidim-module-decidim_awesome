# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContentSecurityPolicy
      extend ActiveSupport::Concern

      included do
        after_action :append_awesome_csp_directives
      end

      private

      def append_awesome_csp_directives
        # this is necessary for custom fields
        content_security_policy.append_csp_directive("font-src", "data:") if DecidimAwesome.enabled?(:proposal_custom_fields)
        append_awesome_intergram_directives
      end

      def append_awesome_intergram_directives
        return unless DecidimAwesome.enabled?(:intergram_for_admins) || DecidimAwesome.enabled?(:intergram_for_public)

        intergram = URI.parse(DecidimAwesome.intergram_url)
        if intergram.host && intergram.scheme
          content_security_policy.append_csp_directive("script-src", "#{intergram.scheme}://#{intergram.host}")
          content_security_policy.append_csp_directive("frame-src", "#{intergram.scheme}://#{intergram.host}")
          # this is commetes in the intergram github, but does not look necessary
          # content_security_policy.append_csp_directive("frame-src", "http://www.loadmill.com")
          # content_security_policy.append_csp_directive("frame-src", "http://app.loadmill.com")
        end
      end
    end
  end
end
