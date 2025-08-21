# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module NeedsConstraintHelpers
        private

        attr_reader :organization, :config_var

        def ident
          @ident ||= rand(36**8).to_s(36)
        end

        def find_var
          @find_var ||= AwesomeConfig.find_or_initialize_by(var: config_var, organization:)
        end

        def find_sub_var
          @find_sub_var ||= AwesomeConfig.find_or_initialize_by(var: "#{config_var.to_s.singularize}_#{ident}", organization:)
        end

        def create_array_config!(default_attributes = nil)
          find_var.value = [] unless find_var.value.is_a?(Array)
          find_var.value << default_attributes if default_attributes
          find_var.save!
          find_var
        end

        def create_hash_config!(default_attributes = nil)
          find_var.value = {} unless find_var.value.is_a?(Hash)
          find_var.value[ident] = default_attributes if default_attributes
          find_var.save!
          find_var
        end

        def destroy_hash_ident!
          find_var.value.except!(ident)
          find_var.save!

          # remove associated sub var (dependents will be destroyed automatically via ActiveRecord triggers)
          find_sub_var.destroy! if find_sub_var.present?
        end

        def create_constraint_never!
          @constraint = ConfigConstraint.create!(
            awesome_config: find_sub_var,
            settings: { "participatory_space_manifest" => "none" }
          )
        end

        def constraint_can_be_destroyed?(constraint)
          return true if constraint.awesome_config.blank?
          return true if constraint.awesome_config.constraints.count > 1

          case constraint.awesome_config.var.to_s
          when /^proposal_(private_)?custom_field/
            false
          else
            true
          end
        end
      end
    end
  end
end
