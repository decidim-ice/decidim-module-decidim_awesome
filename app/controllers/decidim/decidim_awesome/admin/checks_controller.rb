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
            ['<%= stylesheet_pack_tag "decidim_decidim_awesome", media: "all" %>',
             '<%= render(partial: "layouts/decidim/decidim_awesome/custom_styles") if awesome_custom_styles %>'].join("\n")
          when :JavaScript
            ['<%= render partial: "layouts/decidim/decidim_awesome/awesome_config" %>',
             '<%= javascript_pack_tag "decidim_decidim_awesome" %>',
             '<%= javascript_pack_tag "decidim_decidim_awesome_proposals_custom_fields" if awesome_proposal_custom_fields %>'].join("\n")
          end
        end

        def admin_addons(part)
          case part
          when :CSS
            '<%= stylesheet_pack_tag "decidim_admin_decidim_awesome", media: "all" %>'
          when :JavaScript
            ['<%= javascript_pack_tag "decidim_admin_decidim_awesome", defer: false %>',
             '<%= javascript_pack_tag "decidim_decidim_awesome_proposals_custom_fields" if awesome_proposal_custom_fields %>'].join("\n")
          end
        end
      end
    end
  end
end
