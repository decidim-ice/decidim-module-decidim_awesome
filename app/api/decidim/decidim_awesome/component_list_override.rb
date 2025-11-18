# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ComponentListOverride
      extend ActiveSupport::Concern

      included do
        alias_method :decidim_call, :call

        def call(participatory_space, args, ctx)
          decidim_call(participatory_space, args, ctx).where.not(id: service(participatory_space).component_with_invisible_resources)
                                                      .where.not(participatory_space: service(participatory_space).spaces_with_invisible_components)
        end
      end

      def service(participatory_space)
        @services ||= {}
        @services[participatory_space.id] ||= Decidim::DecidimAwesome::UserGrantedAuthorizationsService.new(participatory_space.organization, nil)
      end
    end
  end
end
