# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # A mailer for sending notifications to respondents when the admin team
    # replies to their follow-up questionnaire submission.
    class FollowUpQuestionnaireMessageMailer < Decidim::ApplicationMailer
      def self.reply_to_email(organization)
        sender = organization.smtp_settings&.dig("from_email").presence || Decidim.config.mailer_sender
        Mail::Address.new(sender).address
      end

      def notification(message, email, name, status_changed: false)
        @message = message
        @name = name
        @organization = message.organization
        @status_changed = status_changed

        attach_files

        # i18n-tasks-use t('decidim.decidim_awesome.follow_up_questionnaire_message_mailer.notification.subject')
        I18n.with_locale(recipient_locale) do
          mail(to: email, reply_to: self.class.reply_to_email(@organization),
               subject: default_i18n_subject(questionnaire: translated_attribute(message.follow_up_questionnaire.name)))
        end
      end

      private

      def recipient_locale
        recipient_user&.locale || @organization.default_locale
      end

      def recipient_user
        Decidim::User.find_by(id: @message.decidim_user_id) if @message.decidim_user_id
      end

      def attach_files
        @message.attachments.with_attached_file.each do |attachment|
          next unless attachment.file.attached?

          attachments[attachment.file.filename.to_s] = attachment.file.download
        end
      end
    end
  end
end
