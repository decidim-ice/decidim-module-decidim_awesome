# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class DestroyAuthorizationGroup < Command
        def initialize(key, organization)
          @key = key
          @organization = organization
        end

        def call
          groups = AwesomeConfig.find_by(var: :authorization_groups, organization: @organization)
          return broadcast(:invalid, "Not a hash") unless groups&.value.is_a?(Hash)
          return broadcast(:invalid, "#{@key} key invalid") unless groups.value.has_key?(@key)

          groups.value.except!(@key)
          groups.save!

          constraint = AwesomeConfig.find_by(var: "authorization_groups_#{@key}", organization: @organization)
          constraint.destroy! if constraint.present?

          broadcast(:ok, @key)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end
      end
    end
  end
end
