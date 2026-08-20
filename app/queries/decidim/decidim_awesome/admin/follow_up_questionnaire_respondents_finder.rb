# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # Resolves the name/email/processability of follow-up questionnaire respondents.
      # Registered users are resolved through their Decidim::User account; anonymous
      # respondents are resolved through the questionnaire's configured responder
      # name/email questions. Response lookups are memoized so building many
      # respondents from the same instance only queries the responses once.
      class FollowUpQuestionnaireRespondentsFinder
        include Decidim::TranslatableAttributes

        Respondent = Struct.new(:name, :email, :processable, keyword_init: true) do
          def processable?
            processable
          end
        end

        def initialize(follow_up_questionnaire)
          @follow_up_questionnaire = follow_up_questionnaire
        end

        def respondent_for(decidim_user_id: nil, session_token: nil)
          if decidim_user_id.present?
            user = Decidim::User.find_by(id: decidim_user_id)
            return Respondent.new(name: user&.name, email: user&.email, processable: user.present?)
          end

          name = response_body(follow_up_questionnaire.responder_name_field, session_token, name_responses)
          email = response_body(follow_up_questionnaire.responder_email_field, session_token, email_responses)
          Respondent.new(name:, email:, processable: name.present? || email.present?)
        end

        private

        attr_reader :follow_up_questionnaire

        def name_responses
          @name_responses ||= responses_for_question(follow_up_questionnaire.responder_name_field)
        end

        def email_responses
          @email_responses ||= responses_for_question(follow_up_questionnaire.responder_email_field)
        end

        def responses_for_question(question_id)
          return {} if question_id.blank?

          Decidim::Forms::Response.where(questionnaire: follow_up_questionnaire.questionnaire, decidim_question_id: question_id)
                                  .index_by { |response| response.decidim_user_id || response.session_token }
        end

        def response_body(question_id, session_token, responses)
          return if question_id.blank?

          response = responses[session_token]
          return if response.blank?

          translated_attribute(response.body)
        end
      end
    end
  end
end
