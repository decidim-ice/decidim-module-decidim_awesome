# frozen_string_literal: true

require "decidim/decidim_awesome/railtie" if defined? Rails
require "decidim/decidim_awesome/admin"
require "decidim/decidim_awesome/engine"
require "decidim/decidim_awesome/admin_engine"
require "decidim/decidim_awesome/content_renderers"
require "decidim/decidim_awesome/context_analyzers"

module Decidim
  module DecidimAwesome
    include ActiveSupport::Configurable

    autoload :Config, "decidim/decidim_awesome/config"
    autoload :ContentRenderes, "decidim/decidim_awesome/content_renderers"
    autoload :ContextAnalyzers, "decidim/decidim_awesome/context_analyzers"

    config_accessor :allow_images_in_full_editor do
      false
    end

    config_accessor :allow_images_in_small_editor do
      false
    end

    config_accessor :allow_images_in_proposals do
      false
    end

    config_accessor :use_markdown_in_proposals do
      false
    end
  end
end
