# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module NeedsDefaultConstraints
        private

        def create_default_constraints(var)
          settings = { "participatory_space_manifest" => "none" }
          subconfig = AwesomeConfig.find_or_initialize_by(var: "#{var}_#{@ident}", organization: @organization)
          @constraint = ConfigConstraint.create!(
            awesome_config: subconfig,
            settings: settings
          )
        end
      end
    end
  end
end
