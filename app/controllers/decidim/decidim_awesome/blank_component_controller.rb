# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # Abstract component class for components without any admin controllers (only settings)
    class BlankComponentController < Decidim::Components::BaseController
      # just redirects to settings
      def settings
        redirect_to EngineRouter.admin_proxy(component.participatory_space).edit_component_path(id: component)
      end

      private

      def set_component_breadcrumb_item
        context_breadcrumb_items << {
          label: current_component.name,
          url: EngineRouter.admin_proxy(component.participatory_space).edit_component_path(id: component),
          active: false,
          resource: current_component
        }
      end

      def component
        Decidim::Component.find(params[:component_id])
      end
    end
  end
end
