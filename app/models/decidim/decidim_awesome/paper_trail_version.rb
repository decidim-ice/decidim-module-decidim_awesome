# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class PaperTrailVersion < PaperTrail::Version
      default_scope { order("created_at DESC") }
      scope :role_actions, -> { where(item_type: ::Decidim::DecidimAwesome.admin_user_roles, event: "create") }

      def present
        @present ||= if item_type.in?(Decidim::DecidimAwesome.admin_user_roles)
                       PaperTrailRolePresenter.new(self)
                     else
                       self
                     end
      end
    end
  end
end
