# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateAuthorizationGroup < Command
        include NeedsConstraintHelpers

        def initialize(organization)
          @organization = organization
          @ident = rand(36**8).to_s(36)
        end

        def call
          groups = AwesomeConfig.find_or_initialize_by(var: :authorization_groups, organization: @organization)
          groups.value ||= {}
          groups.value[@ident] = {
            "authorization_handlers" => [],
            "authorization_handlers_options" => {},
            "force_authorization_with_any_method" => false,
            "force_authorization_help_text" => {}
          }

          groups.save!

          create_constraint_never(:authorization_groups)

          broadcast(:ok, @ident)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end
      end
    end
  end
end
