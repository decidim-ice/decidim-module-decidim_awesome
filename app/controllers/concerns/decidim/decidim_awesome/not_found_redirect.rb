# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module NotFoundRedirect
      extend ActiveSupport::Concern

      included do
        before_action :redirect_unallowed_scoped_admins, only: :not_found, if: -> { request.original_fullpath =~ %r{^(/+)admin} }
        before_action :redirect_to_custom_paths, only: :not_found, if: -> { DecidimAwesome.enabled? :custom_redirects }
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
          destination = custom_redirects_destination(request.original_fullpath)
          redirect_to destination if destination.present?
        end

        def custom_redirects_destination(fullpath)
          redirects = (AwesomeConfig.find_by(var: :custom_redirects, organization: current_organization)&.value || {}).filter { |_, v| v["active"] }
          return if redirects.blank?
          return unless redirects.is_a? Hash

          path, query = fullpath.split("?")
          destination = redirects.dig(path.downcase, "destination")
          pass_query = redirects.dig(path.downcase, "pass_query")
          if pass_query.present?
            union = destination.include?("?") ? "&" : "?"
            destination = "#{destination}#{union}#{query}"
          end

          return destination.strip if destination.present?
        end
      end
    end
  end
end
