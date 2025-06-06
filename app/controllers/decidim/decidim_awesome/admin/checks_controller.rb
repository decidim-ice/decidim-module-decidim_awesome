# frozen_string_literal: true

require "decidim/decidim_awesome/version"

module Decidim
  module DecidimAwesome
    module Admin
      # System compatibility analyzer
      class ChecksController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        include MaintenanceContext

        helper ConfigConstraintsHelpers
        helper SystemCheckerHelpers

        helper_method :head, :admin_head, :head_addons, :admin_addons

        private

        def head
          @head ||= Nokogiri::HTML(render_template("decidim/decidim_awesome/admin/checks/assets_tester"))
        end

        def admin_head
          @admin_head = Nokogiri::HTML(render_template("layouts/decidim/admin/header"))
        end

        def head_addons(part)
          case part
          when :CSS
            ['<%= append_stylesheet_pack_tag "decidim_decidim_awesome", media: "all" %>',
             '<%= render(partial: "layouts/decidim/decidim_awesome/custom_styles") if awesome_scoped_styles %>'].join("\n")
          when :JavaScript
            ['<%= render partial: "layouts/decidim/decidim_awesome/awesome_config" %>',
             '<%= append_javascript_pack_tag "decidim_decidim_awesome", defer: false %>',
             '<%= append_javascript_pack_tag "decidim_decidim_awesome_custom_fields" if awesome_proposal_custom_fields %>'].join("\n")
          end
        end

        def admin_addons(part)
          case part
          when :CSS
            '<%= append_stylesheet_pack_tag "decidim_admin_decidim_awesome", media: "all" %>'
          when :JavaScript
            ['<%= append_javascript_pack_tag "decidim_admin_decidim_awesome", defer: false %>',
             '<%= append_javascript_pack_tag "decidim_decidim_awesome_custom_fields" if awesome_proposal_custom_fields %>'].join("\n")
          end
        end

        def render_template(partial)
          render_to_string(partial:)
        rescue ActionView::Template::Error => e
          flash.now[:alert] = "Partial [#{partial}] has thrown an error: #{e.message}"
        end
      end
    end
  end
end
