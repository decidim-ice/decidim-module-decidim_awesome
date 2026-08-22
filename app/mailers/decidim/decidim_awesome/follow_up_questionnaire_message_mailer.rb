# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # A mailer for sending notifications to respondents when the admin team
    # replies to their follow-up questionnaire submission.
    class FollowUpQuestionnaireMessageMailer < Decidim::ApplicationMailer
      def notification(message, email, name)
        @message = message
        @name = name
        @organization = message.organization

        # i18n-tasks-use t('decidim.decidim_awesome.follow_up_questionnaire_message_mailer.notification.subject')
        I18n.with_locale(recipient_locale) do
          mail(to: email, subject: default_i18n_subject(questionnaire: translated_attribute(message.follow_up_questionnaire.name)))
        end
      end

      private

      def recipient_locale
        recipient_user&.locale || @organization.default_locale
      end

      def recipient_user
        Decidim::User.find_by(id: @message.decidim_user_id) if @message.decidim_user_id
      end
    end
  end
end
