# frozen_string_literal: true

require "decidim/decidim_awesome/version"

module Decidim
  # add a global helper with awesome configuration
  module DecidimAwesome
    module AwesomeHelpers
      # Returns the normalized config for an Organization and the current url
      def awesome_config_instance
        return @awesome_config_instance if @awesome_config_instance

        @awesome_config_instance = Config.new request.env["decidim.current_organization"]
        @awesome_config_instance.context_from_request request
        @awesome_config_instance
      end

      def awesome_config
        @awesome_config ||= awesome_config_instance.config
      end

      def javascript_config_vars
        awesome_config.except(:scoped_styles, :proposal_custom_fields).to_json.html_safe
      end

      def show_public_intergram?
        return unless awesome_config[:intergram_for_public]
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

      def tenant_stylesheets
        return @tenant_stylesheets if @tenant_stylesheets

        prefix = Rails.root.join("app", "assets", "themes", current_organization.host)
        return @tenant_stylesheets = current_organization.host.to_s if File.exist?("#{prefix}.css") || File.exist?("#{prefix}.scss") || File.exist?("#{prefix}.scss.erb")
      end

      # Collects all CSS that is applied in the current URL context
      def awesome_custom_styles
        @awesome_custom_styles ||= awesome_collect_sub_configs("scoped_style", awesome_config_instance)
      end

      # Collects all proposal custom fields that is applied in the current URL context
      def awesome_proposal_custom_fields
        @awesome_proposal_custom_fields ||= awesome_collect_sub_configs("proposal_custom_field", awesome_config_instance)
      end

      def awesome_collect_sub_configs(singular_key, config_instance)
        plural_key = singular_key.pluralize.to_sym
        return unless awesome_config[plural_key]

        fields = awesome_config[plural_key]&.filter do |key, _value|
          config = AwesomeConfig.find_by(var: "#{singular_key}_#{key}", organization: current_organization)
          config_instance.valid_in_context?(config&.constraints)
        end
        fields.values
      end

      def version_prefix
        "v#{Decidim.version[0..3]}"
      end
    end
  end
end
