# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateFollowUpQuestionnaireMessage < Command
        include Decidim::MultipleAttachmentsMethods

        def initialize(form)
          @form = form
        end

        def call
          return broadcast(:invalid) if form.invalid?

          if process_attachments?
            build_attachments
            return broadcast(:invalid) if attachments_invalid?
          end

          transaction do
            create_message
            @attached_to = message
            create_attachments if process_attachments?
            notify_respondent
          end

          broadcast(:ok, message)
        end

        private

        attr_reader :form, :message

        def create_message
          @message = Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.create!(
            follow_up_questionnaire_id: form.follow_up_questionnaire_id,
            status_id: form.status_id,
            body: form.body,
            author: form.current_user,
            decidim_user_id: form.decidim_user_id,
            session_token: form.session_token
          )
        end

        def notify_respondent
          respondent = respondents_finder.respondent_for(decidim_user_id: message.decidim_user_id, session_token: message.session_token)
          return unless respondent.processable? && respondent.email.present?

          FollowUpQuestionnaireMessageMailer.notification(message, respondent.email, respondent.name).deliver_later
        end

        def respondents_finder
          @respondents_finder ||= FollowUpQuestionnaireRespondentsFinder.new(message.follow_up_questionnaire)
        end
      end
    end
  end
end
