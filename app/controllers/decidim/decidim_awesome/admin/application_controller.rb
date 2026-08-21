# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      #
      # Note that it inherits from `Decidim::Admin::Components::BaseController`, which
      # override its layout and provide all kinds of useful methods.
      class ApplicationController < Decidim::Admin::ApplicationController
        layout "decidim/decidim_awesome/admin/application"

        def permission_class_chain
          [::Decidim::DecidimAwesome::Admin::Permissions] + super
        end

        before_action do
          enforce_permission_to :update, :organization, organization: current_organization
        end
      end
    end
  end
end
