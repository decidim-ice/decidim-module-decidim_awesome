# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ParticipatorySpaceListBaseOverride
      extend ActiveSupport::Concern

      included do
        alias_method :decidim_call, :call

        def call(obj, args, ctx)
          decidim_call(obj, args, ctx).where.not(id: service(ctx[:current_organization]).spaces_with_invisible_components)
        end
      end

      def service(organization)
        @services ||= {}
        @services[organization.id] ||= Decidim::DecidimAwesome::UserGrantedAuthorizationsService.new(organization, nil)
      end
    end
  end
end
