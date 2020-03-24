# frozen_string_literal: true

require "decidim/decidim_awesome/awesome_helpers"

module Decidim
  # add a global helper with awesome configuration
  module DecidimAwesome
    class Railtie < Rails::Railtie
      initializer "decidim_awesome.view_helpers" do
        ActionView::Base.send :include, AwesomeHelpers
      end
    end
  end
end
