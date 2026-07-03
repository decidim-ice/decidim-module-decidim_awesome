# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Verifications
      # This module overrides the default behavior of the Decidim::Verifications::ApplicationHelper module.
      # It provides a custom representation of the authorization explanation for the awesome_authorization_handler.
      module ApplicationHelperOverride
        extend ActiveSupport::Concern

        included do
          alias_method :decidim_granted_authorization_explanation, :granted_authorization_explanation

          # Overrides the default behavior of the granted_authorization_explanation method.
          # It adds the groups of the user to the explanation if the authorization handler is awesome_authorization_handler.
          def granted_authorization_explanation(authorization)
            explanation = decidim_granted_authorization_explanation(authorization)
            if authorization.name == "awesome_authorization_handler"
              groups = authorization.metadata["groups"]&.values&.map { |name| translated_attribute(name) }
              explanation += ". #{I18n.t("decidim.decidim_awesome.awesome_authorization_handler.member_of", groups: "\"#{groups.join('", "')}")}\"" if groups.present?
            end
            explanation
          end
        end
      end
    end
  end
end
