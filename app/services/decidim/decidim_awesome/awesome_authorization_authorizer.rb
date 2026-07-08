# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class AwesomeAuthorizationAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
      protected

      def unmatched_fields
        @unmatched_fields ||= begin
          unmatched = super.except("awesome_authorization_groups")
          selected_group_ids = selected_authorization_group_ids
          return unmatched if selected_group_ids.blank?

          authorized_group_ids = authorization.metadata.fetch("groups", {}).keys.map(&:to_s)
          return unmatched if (selected_group_ids & authorized_group_ids).any?

          unmatched.merge("awesome_authorization_groups" => selected_group_ids)
        end
      end

      def missing_fields
        @missing_fields ||= super - ["awesome_authorization_groups"]
      end

      private

      def selected_authorization_group_ids
        raw_value = options["awesome_authorization_groups"]
        value = raw_value.respond_to?(:value) ? raw_value.value : raw_value

        case value
        when Array
          value
        else
          value.to_s.split(",")
        end.map(&:to_s).map(&:strip).reject(&:blank?)
      end
    end
  end
end
