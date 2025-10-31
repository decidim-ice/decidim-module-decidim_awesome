# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module LastActivityOverride
      extend ActiveSupport::Concern

      included do
        alias_method :decidim_query, :query

        def query
          @awesome_query ||= begin
            query = filter_invisible_spaces(decidim_query)
            filter_invisible_components(query)
          end
        end

        def filter_invisible_spaces(query)
          spaces_with_restrictions = awesome_service.spaces_with_invisible_components
          query.where.not(participatory_space: spaces_with_restrictions)
        end

        def filter_invisible_components(query)
          components_with_restrictions = awesome_service.component_with_invisible_resources
          query.where.not(component: components_with_restrictions)
        end

        private

        def awesome_service
          @awesome_service ||= UserGrantedAuthorizationsService.new(organization, current_user)
        end
      end
    end
  end
end
