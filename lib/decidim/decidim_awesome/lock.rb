# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class Lock
      def initialize(organization, lock_time: DecidimAwesome.lock_time)
        @organization = organization
        @lock_time = lock_time
      end

      attr_reader :resource, :organization, :lock_time

      def get!(resource)
        @resource = resource
        if config
          config.update!(updated_at: Time.current)
        else
          AwesomeConfig.create!(var: var, organization: organization)
        end
      end

      def release!(resource)
        @resource = resource
        config.destroy! if config
      end

      def locked?(resource)
        @resource = resource
        return false unless config
        return true if config.reload.updated_at > lock_time.ago

        config.destroy!
        false
      end

      def config
        AwesomeConfig.find_by(var: var, organization: organization)
      end

      private

      def var
        "lock-#{resource.class.name.underscore}_#{resource.id}"
      end
    end
  end
end
