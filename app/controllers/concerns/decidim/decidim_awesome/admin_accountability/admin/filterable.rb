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

            private

            def base_query
              collection
            end

            def filters
              [
                :role_type_eq,
                :participatory_space_type_eq
              ]
            end

            def filters_with_values
              {
                role_type_eq: role_types,
                participatory_space_type_eq: participatory_space_types
              }
            end

            def dynamically_translated_filters
              [:role_type_eq, :participatory_space_type_eq]
            end

            def translated_role_type_eq(role)
              admin_action = collection.find { |action| action.item && action.item[:role] == role }
              admin_action ? translated_attribute(admin_action.item[:role]) : nil
            end

            def translated_participatory_space_type_eq(item_type)
              admin_action = collection.find { |action| action.item_type == item_type }
              admin_action ? translated_attribute(admin_action.item_type.demodulize.gsub("UserRole", "")) : nil
            end

            def search_field_predicate
              :user_name_or_user_email_cont
            end

            def extra_allowed_params
              [:per_page]
            end

            def participatory_space_types
              collection.pluck(:item_type).uniq.sort
            end

            def role_types
              collection.map { |admin_action| admin_action.item&.[](:role) }.compact.uniq.sort
            end
          end
        end
      end
    end
  end
end
