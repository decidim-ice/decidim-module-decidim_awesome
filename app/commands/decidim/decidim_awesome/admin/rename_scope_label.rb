# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class RenameScopeLabel < Command
        # Public: Initializes the command.
        #
        # params - A constraint params
        def initialize(params, organization)
          # rubocop:disable Style/SafeNavigationChainLength
          @text = params[:text]&.strip&.gsub(" ", "_")&.parameterize&.truncate(64)
          # rubocop:enable Style/SafeNavigationChainLength
          @scope = params[:scope]
          @key = params[:key]
          @attribute = params[:attribute]
          @organization = organization
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if we couldn't proceed.
        #
        # Returns nothing.
        def call
          raise StandardError, "empty value" if @text.blank?
          raise StandardError, "key already exists" if config.value.keys.include? @text

          transaction do
            config.value[@text] = config.value.delete @key
            config.save!
            if config_scope
              config_scope.var = scope
              config_scope.save!
            end
          end

          broadcast(:ok, { scope:, key: @text })
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        def scope
          @scope.gsub(/_#{@key}$/, "_#{@text}")
        end

        def config
          @config ||= Decidim::DecidimAwesome::AwesomeConfig.find_by!(var: @attribute, organization: @organization)
        end

        def config_scope
          @config_scope ||= Decidim::DecidimAwesome::AwesomeConfig.find_by(var: @scope, organization: @organization)
        end
      end
    end
  end
end
