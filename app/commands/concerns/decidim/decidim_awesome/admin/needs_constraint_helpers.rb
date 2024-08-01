# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module NeedsConstraintHelpers
        private

        def create_constraint_never(var)
          settings = { "participatory_space_manifest" => "none" }
          subconfig = AwesomeConfig.find_or_initialize_by(var: "#{var}_#{@ident}", organization: @organization)
          @constraint = ConfigConstraint.create!(
            awesome_config: subconfig,
            settings:
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
