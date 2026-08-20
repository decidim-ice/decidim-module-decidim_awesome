# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateFollowUpQuestionnaire < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form or the record could not be saved.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          follow_up_questionnaire = Decidim::DecidimAwesome::FollowUpQuestionnaire.new(form.to_params)

          if follow_up_questionnaire.save
            broadcast(:ok, follow_up_questionnaire)
          else
            broadcast(:invalid, follow_up_questionnaire.errors.full_messages.join(", "))
          end
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form
      end
    end
  end
end
