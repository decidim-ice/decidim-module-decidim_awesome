# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class DestroyFollowUpQuestionnaire < Decidim::Command
        # Public: Initializes the command.
        #
        # follow_up_questionnaire - The FollowUpQuestionnaire to destroy.
        def initialize(follow_up_questionnaire)
          @follow_up_questionnaire = follow_up_questionnaire
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the record could not be destroyed.
        #
        # Returns nothing.
        def call
          follow_up_questionnaire.destroy!

          broadcast(:ok)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :follow_up_questionnaire
      end
    end
  end
end
