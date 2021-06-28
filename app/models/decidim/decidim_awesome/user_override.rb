# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module UserOverride
      extend ActiveSupport::Concern

      included do
        class << self
          attr_accessor :awesome_admins_for_current_scope
        end

        # TODO: Assign admin if is a constraint exists for the current_context
        # TODO: add a middleware to store the current context
        def admin
          return self["admin"] if self["admin"]

          Decidim::User.awesome_admins_for_current_scope.include? id
        end

        def admin?
          admin.present?
        end
      end
    end
  end
end
