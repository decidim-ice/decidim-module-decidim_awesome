# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module AdminNotFoundRedirect
      extend ActiveSupport::Concern

      included do
        # rubocop:disable Rails/LexicallyScopedActionFilter:
        before_action :redirect_unallowed_scoped_admins, only: :not_found
        # rubocop:enable Rails/LexicallyScopedActionFilter

        private

        def redirect_unallowed_scoped_admins
          return unless request.original_fullpath =~ %r{^(/+)admin}
          return unless Decidim::User.respond_to? :awesome_potential_admins
          return unless defined? current_user
          return unless Decidim::User.awesome_potential_admins.include? current_user.id

          # assiging a flash message here does not work after redirection due the order of middleware in Rails
          # as a workaround, send a message through a get parameter
          path = "/admin/?unauthorized"
          referer = request.headers["Referer"]
          if referer
            uri = URI(referer)
            params = Rack::Utils.parse_query uri.query
            unless request.params.has_key? "unauthorized"
              params["unauthorized"] = nil
              path = "#{uri.path}?#{Rack::Utils.build_query(params)}"
            end
          end

          redirect_to path
        end
      end
    end
  end
end
