# frozen_string_literal: true

require "decidim/decidim_awesome/version"

module Decidim
  # add a global helper with awesome configuration
  module DecidimAwesome
    module AwesomeHelpers
      include RequestMemoizer

      # Returns the normalized config for an Organization and the current url
      def awesome_config_instance
        memoize("current_config") do
          config = Config.new(request.env["decidim.current_organization"])
          config.context_from_request(request)
          config
        end
      end

      def awesome_config
        memoize("awesome_config") do
          awesome_config_instance.config
        end
      end

      def javascript_config_vars
        memoize("javascript_config_vars") do
          awesome_config.slice(:allow_images_in_proposals, :allow_images_in_editors, :allow_videos_in_editors, :auto_save_forms).to_json.html_safe
        end
      end

      def show_public_intergram?
        return false unless awesome_config[:intergram_for_public]
        return true unless awesome_config[:intergram_for_public_settings][:require_login]

        user_signed_in?
      end

      def unfiltered_awesome_config
        memoize("unfiltered_awesome_config") do
          awesome_config_instance.unfiltered_config
        end
      end

      def organization_awesome_config
        memoize("organization_awesome_config") do
          awesome_config_instance.organization_config
        end
      end

      def awesome_version
        ::Decidim::DecidimAwesome::VERSION
      end

      # Collects all CSS that is applied in the current URL context
      def awesome_scoped_styles
        memoize("awesome_scoped_styles") do
          awesome_config_instance.collect_sub_configs_values("scoped_style")
        end
      end

      # Collects all CSS that is applied in the current URL context
      def awesome_scoped_admin_styles
        memoize("awesome_scoped_admin_styles") do
          awesome_config_instance.collect_sub_configs_values("scoped_admin_style")
        end
      end

      # Collects all proposal custom fields that is applied in the current URL context
      def awesome_scoped_admins
        memoize("awesome_scoped_admins") do
          awesome_config_instance.collect_sub_configs_values("scoped_admin")
        end
      end

      # Collects all proposal custom fields that is applied in the current URL context
      def awesome_proposal_custom_fields
        memoize("awesome_proposal_custom_fields") do
          awesome_config_instance.collect_sub_configs_values("proposal_custom_field")
        end
      end

      def awesome_proposal_private_custom_fields
        memoize("awesome_proposal_private_custom_fields") do
          awesome_config_instance.collect_sub_configs_values("proposal_private_custom_field")
        end
      end

      # Collects all the force authorizations that is applied in the current URL context
      def awesome_force_authorizations
        memoize("awesome_force_authorizations") do
          awesome_config_instance.collect_sub_configs_values("force_authorization")
        end
      end

      # this will check if the current component has been configured to use a custom voting manifest
      def awesome_voting_manifest_for(component)
        memoize("awesome_voting_manifest_for_#{component.id}") do
          DecidimAwesome.voting_registry.find(component.settings.try(:awesome_voting_manifest))
        end
      end

      # Retrieves all the "admins_available_authorizations" for the user along with other possible authorizations
      # returns an instance of Decidim::DecidimAwesome::Authorizer
      def awesome_authorizations_for(user)
        memoize("awesome_authorizations_for_#{user.id}") do
          Authorizer.new(user, awesome_config[:admins_available_authorizations])
        end
      end

      def version_prefix
        "v#{Decidim.version[0..3]}"
      end
    end
  end
end
