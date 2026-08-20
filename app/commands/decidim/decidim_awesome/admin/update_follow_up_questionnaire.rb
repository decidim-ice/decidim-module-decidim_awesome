# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UpdateFollowUpQuestionnaire < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # follow_up_questionnaire - The FollowUpQuestionnaire to update (may be a new,
        #                           not yet persisted, record).
        def initialize(form, follow_up_questionnaire)
          @form = form
          @follow_up_questionnaire = follow_up_questionnaire
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form or the record could not be saved.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          if follow_up_questionnaire.update(form.to_params)
            broadcast(:ok, follow_up_questionnaire)
          else
            broadcast(:invalid, follow_up_questionnaire.errors.full_messages.join(", "))
          end
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form, :follow_up_questionnaire
      end
    end
  end
end
