# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module NotFoundRedirect
      extend ActiveSupport::Concern

      included do
        before_action :redirect_unallowed_scoped_admins, only: :not_found, if: -> { request.original_fullpath =~ %r{^(/+)admin} }
        before_action :redirect_to_custom_paths, only: :not_found, unless: -> { request.original_fullpath =~ %r{^(/+)admin} }
        private

        def redirect_unallowed_scoped_admins
          return unless Decidim::User.respond_to? :awesome_admins_for_current_scope
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

        def redirect_to_custom_paths
          return if DecidimAwesome.config[:custom_redirects] == :disabled

          redirect_to "/" if request.original_fullpath == "/asdf"
        end
      end
    end
  end
end