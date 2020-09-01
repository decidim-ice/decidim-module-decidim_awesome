# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class MapController < DecidimAwesome::ApplicationController
      helper_method :current_component, :current_participatory_space

      def show
        render
      end

      private

      def current_component
        @current_component ||= Decidim::Component.find(params[:component_id])
      end

      def current_participatory_space
        @current_component.participatory_space
      end
    end
  end
end
