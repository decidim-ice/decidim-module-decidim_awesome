# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class AwesomeAuthorizationAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
      include Decidim::SanitizeHelper

      protected

      def unmatched_fields
        @unmatched_fields ||= begin
          unmatched = super.except("awesome_authorization_groups")
          return unmatched if selected_group_ids.blank?

          authorized_group_ids = authorization.metadata.fetch("groups", {}).keys.map(&:to_s)
          return unmatched if (selected_group_ids & authorized_group_ids).any?

          unmatched.merge("awesome_authorization_groups" => allowed_group_names)
        end
      end

      def missing_fields
        @missing_fields ||= super - ["awesome_authorization_groups"]
      end

      private

      def selected_group_ids
        @selected_group_ids ||= options["awesome_authorization_groups"].to_s.split(",").map(&:strip).reject(&:blank?).uniq
      end

      def allowed_group_names
        authorization.metadata["groups"].map do |group_id, group_data|
          decidim_sanitize_translated(group_data) || group_id
        end.join(", ")
      end
    end
  end
end
