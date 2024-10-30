# frozen_string_literal: true

require "decidim/decidim_awesome/version"

module Decidim
  # add a global helper with awesome configuration
  module DecidimAwesome
    module AwesomeHelpers
      # Returns the normalized config for an Organization and the current url
      def awesome_config_instance
        return @awesome_config_instance if @awesome_config_instance

        # if already created in the middleware, reuse it as it might have additional constraints
        @awesome_config_instance = request.env["decidim_awesome.current_config"]
        unless @awesome_config_instance.is_a? Config
          @awesome_config_instance = Config.new request.env["decidim.current_organization"]
          @awesome_config_instance.context_from_request request
        end
        @awesome_config_instance
      end

      def awesome_config
        @awesome_config ||= awesome_config_instance.config
      end

      def javascript_config_vars
        awesome_config.except(:scoped_styles, :scoped_admin_styles, :proposal_custom_fields, :proposal_private_custom_fields, :scoped_admins).to_json.html_safe
      end

      def show_public_intergram?
        return false unless awesome_config[:intergram_for_public]
        return true unless awesome_config[:intergram_for_public_settings][:require_login]

        user_signed_in?
      end

      def unfiltered_awesome_config
        @unfiltered_awesome_config ||= awesome_config_instance.unfiltered_config
      end

      def organization_awesome_config
        @organization_awesome_config ||= awesome_config_instance.organization_config
      end

      def awesome_version
        ::Decidim::DecidimAwesome::VERSION
      end

      # Collects all CSS that is applied in the current URL context
      def awesome_scoped_styles
        @awesome_scoped_styles ||= awesome_config_instance.collect_sub_configs_values("scoped_style")
      end

      # Collects all CSS that is applied in the current URL context
      def awesome_scoped_admin_styles
        @awesome_scoped_admin_styles ||= awesome_config_instance.collect_sub_configs_values("scoped_admin_style")
      end

      # Collects all proposal custom fields that is applied in the current URL context
      def awesome_scoped_admins
        @awesome_scoped_admins ||= awesome_config_instance.collect_sub_configs_values("scoped_admin")
      end

      # Collects all proposal custom fields that is applied in the current URL context
      def awesome_proposal_custom_fields
        @awesome_proposal_custom_fields ||= awesome_config_instance.collect_sub_configs_values("proposal_custom_field")
      end

      def awesome_proposal_private_custom_fields
        @awesome_proposal_private_custom_fields ||= awesome_config_instance.collect_sub_configs_values("proposal_private_custom_field")
      end

      # this will check if the current component has been configured to use a custom voting manifest
      def awesome_voting_manifest_for(component)
        return nil unless component.settings.respond_to? :awesome_voting_manifest

        DecidimAwesome.voting_registry.find(component.settings.awesome_voting_manifest)
      end

      # Retrives all the "admins_available_authorizations" for the user along with other possible authorizations
      # returns an instance of Decidim::DecidimAwesome::Authorizator
      def awesome_authorizations_for(user)
        @awesome_authorizations_for ||= {}
        @awesome_authorizations_for[user.id] ||= Authorizator.new(user, awesome_config[:admins_available_authorizations])
      end

      def version_prefix
        "v#{Decidim.version[0..3]}"
      end
    end
  end
end
