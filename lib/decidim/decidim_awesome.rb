# frozen_string_literal: true

require "decidim/decidim_awesome/admin"
require "decidim/decidim_awesome/engine"
require "decidim/decidim_awesome/admin_engine"
require "decidim/decidim_awesome/content_renderers"
require "decidim/decidim_awesome/context_analyzers"
require "decidim/decidim_awesome/map_component/engine"
require "decidim/decidim_awesome/map_component/component"
require "decidim/decidim_awesome/iframe_component/engine"
require "decidim/decidim_awesome/iframe_component/component"

module Decidim
  module DecidimAwesome
    include ActiveSupport::Configurable

    autoload :Config, "decidim/decidim_awesome/config"
    autoload :SystemChecker, "decidim/decidim_awesome/system_checker"
    autoload :ContentRenderes, "decidim/decidim_awesome/content_renderers"
    autoload :ContextAnalyzers, "decidim/decidim_awesome/context_analyzers"

    # Default values for configuration options:
    #   true  => always true but admins can still restrict its scope
    #   false => default false, admins can turn it true
    #   :disabled => false and non available, hidden from admins
    config_accessor :allow_images_in_full_editor do
      false
    end

    config_accessor :allow_images_in_small_editor do
      false
    end

    config_accessor :allow_images_in_proposals do
      false
    end

    config_accessor :use_markdown_editor do
      false
    end

    config_accessor :allow_images_in_markdown_editor do
      false
    end

    config_accessor :auto_save_forms do
      false
    end
  end
end

# Engines to handle logic unrelated to participatory spaces or components

Decidim.register_global_engine(
  :decidim_decidim_awesome, # this is the name of the global method to access engine routes
  ::Decidim::DecidimAwesome::Engine,
  at: "/decidim_awesome"
)

# Decidim.register_global_engine(
#   :decidim_admin_action_awesome,
#   ::Decidim::DecidimAwesome::AdminEngine,
#   at: "/admin/action_awesome"
# )
