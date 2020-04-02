# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    class ApplicationController < Decidim::ApplicationController
      def permission_class_chain
        [::Decidim::DecidimAwesome::Permissions] + super
      end
    end
  end
end
