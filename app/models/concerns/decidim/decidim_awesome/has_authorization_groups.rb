# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module HasAuthorizationGroups
      extend ActiveSupport::Concern

      included do
        has_many :awesome_authorization_groups, foreign_key: "decidim_organization_id", class_name: "Decidim::DecidimAwesome::AuthorizationGroup", dependent: :destroy
      end
    end
  end
end
