# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module DecidimAwesome
    module AdminAccountability
      module Admin
        module Filterable
          extend ActiveSupport::Concern

          included do
            include Decidim::Admin::Filterable

            helper Decidim::DecidimAwesome::AdminAccountability::Admin::FilterableHelper

            private

            def base_query
              collection
            end

            def filters
              [:role_type_eq, :participatory_space_type_eq]
            end

            def filters_with_values
              return { admin_role_type: [] } if global?

              { role_type_eq: role_types, participatory_space_type_eq: participatory_space_types }
            end

            def dynamically_translated_filters
              [:role_type_eq, :participatory_space_type_eq]
            end

            def extra_allowed_params
              [:per_page, :admins, :admin_role_type]
            end

            def translated_role_type_eq(role)
              I18n.t(role, scope: "decidim.decidim_awesome.admin.admin_accountability.roles")
            end

            def translated_participatory_space_type_eq(item_type)
              item_type.gsub("UserRole", "").safe_constantize&.model_name&.human&.pluralize || item_type
            end

            def search_field_predicate
              :user_name_or_user_email_cont
            end

            def participatory_space_types
              @participatory_space_types ||= collection.pluck(:item_type).uniq.sort
            end

            def role_types
              @role_types ||= PaperTrailVersion.safe_user_roles.map do |role_class|
                role_class.safe_constantize.select(:role).distinct.pluck(:role)
              end.union.flatten.sort
            end
          end
        end
      end
    end
  end
end
