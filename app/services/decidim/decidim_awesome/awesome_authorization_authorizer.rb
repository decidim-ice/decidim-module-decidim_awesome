# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class AwesomeAuthorizationAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
      include Decidim::SanitizeHelper

      protected

      def unmatched_fields
        @unmatched_fields ||= begin
          unmatched = super.except("awesome_authorization_groups")
          if selected_group_ids.blank?
            unmatched
          else
            authorized_group_ids = authorization.metadata.fetch("groups", {}).keys.map(&:to_s)

            if selected_group_ids.intersect?(authorized_group_ids)
              unmatched
            else
              unmatched.merge("awesome_authorization_groups" => allowed_group_names)
            end
          end
        end
      end

      def missing_fields
        @missing_fields ||= super - ["awesome_authorization_groups"]
      end

      private

      def selected_group_ids
        @selected_group_ids ||= options["awesome_authorization_groups"].to_s.split(",").map(&:strip).compact_blank.uniq
      end

      def allowed_group_names
        authorization.metadata["groups"].map do |group_id, group_data|
          decidim_sanitize_translated(group_data) || group_id
        end.join(", ")
      end
    end
  end
end
