# frozen_string_literal: true

require "decidim/decidim_awesome/version"

module Decidim
  module DecidimAwesome
    module Admin
      # System compatibility analyzer
      class ChecksController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        helper ConfigConstraintsHelpers

        layout "decidim/admin/decidim_awesome"

        helper_method :overrides, :valid?, :decidim_version, :decidim_version_valid?, :head, :admin_head, :head_addons, :admin_addons

        private

        def head
          @head ||= Nokogiri::HTML(render_to_string(partial: "layouts/decidim/head"))
        end

        def admin_head
          @admin_head = Nokogiri::HTML(render_to_string(partial: "layouts/decidim/admin/header"))
        end

        def overrides
          SystemChecker.to_h
        end

        def valid?(spec, file)
          SystemChecker.valid?(spec, file)
        end

        def decidim_version
          Decidim.version
        end

        def decidim_version_valid?
          Gem::Dependency.new("", DecidimAwesome::COMPAT_DECIDIM_VERSION).match?("", decidim_version, true)
        end

        def head_addons(part)
          case part
          when :CSS
            ['<%= stylesheet_link_tag "decidim/decidim_awesome/application", media: "all" %>',
             '<%= stylesheet_link_tag(tenant_stylesheets, media: "all") if tenant_stylesheets %>'].join("\n")
          when :JavaScript
            ['<%= render partial: "layouts/decidim/decidim_awesome/awesome_config" %>',
             '<%= javascript_include_tag "decidim/decidim_awesome/application" %>'].join("\n")
          end
        end

        def admin_addons(part)
          case part
          when :CSS
            '<%= stylesheet_link_tag "decidim/decidim_awesome/admin", media: "all" %>'
          when :JavaScript
            '<%= javascript_include_tag "decidim/decidim_awesome/admin" %>'
          end
        end
      end
    end
  end
end
