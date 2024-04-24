# frozen_string_literal: true

require "decidim/decidim_awesome/awesome"
require "decidim/decidim_awesome/admin"
require "decidim/decidim_awesome/engine"
require "decidim/decidim_awesome/admin_engine"
require "decidim/decidim_awesome/context_analyzers"
require "decidim/decidim_awesome/map_component/engine"
require "decidim/decidim_awesome/map_component/admin_engine"
require "decidim/decidim_awesome/map_component/component"
require "decidim/decidim_awesome/iframe_component/engine"
require "decidim/decidim_awesome/iframe_component/admin_engine"
require "decidim/decidim_awesome/iframe_component/component"
require "decidim/decidim_awesome/content_parsers/editor_images_parser"

# Engines to handle logic unrelated to participatory spaces or components

Decidim.register_global_engine(
  :decidim_decidim_awesome, # this is the name of the global method to access engine routes
  Decidim::DecidimAwesome::Engine,
  at: "/decidim_awesome"
)
