# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # A value object representing the identity of a follow-up questionnaire
      # respondent, whether they are a registered Decidim::User or an anonymous
      # participant identified through the configured responder name/email questions.
      class FollowUpQuestionnaireRespondent
        attr_reader :name, :email

        def initialize(name:, email:, processable:)
          @name = name
          @email = email
          @processable = processable
        end

        def processable?
          @processable
        end
      end
    end
  end
end
