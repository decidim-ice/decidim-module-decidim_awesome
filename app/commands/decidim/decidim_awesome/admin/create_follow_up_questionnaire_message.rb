# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateFollowUpQuestionnaireMessage < Command
        include Decidim::MultipleAttachmentsMethods
        include Decidim::TranslatableAttributes

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
            @previous_status_id = form.previous_status_id
            create_message
            @attached_to = message
            create_attachments if process_attachments?
            @email_sent = notify_respondent
          end

          broadcast(:ok, message, email_sent)
        end

        private

        attr_reader :form, :message, :previous_status_id, :email_sent

        def create_message
          # The admin log keeps who really sent the message, which may differ from the chosen author
          @message = Decidim.traceability.create!(
            Decidim::DecidimAwesome::FollowUpQuestionnaireMessage,
            form.current_user,
            {
              follow_up_questionnaire_id: form.follow_up_questionnaire_id,
              status_id: form.status_id,
              body: form.body.to_s.strip.presence,
              author: selected_author,
              decidim_user_id: form.decidim_user_id,
              session_token: form.session_token
            },
            resource: log_resource_params
          )
        end

        def log_resource_params
          follow_up_questionnaire = Decidim::DecidimAwesome::FollowUpQuestionnaire.find(form.follow_up_questionnaire_id)
          params = { follow_up_questionnaire_name: translated_attribute(follow_up_questionnaire.name) }
          params[:author_name] = selected_author.name if selected_author && selected_author != form.current_user
          params
        end

        def selected_author
          form.possible_authors.find { |author| author.id == form.author_id }
        end

        def status_changed?
          previous_status_id != message.status_id
        end

        def notify_respondent
          finder = FollowUpQuestionnaireRespondentsFinder.new(message.follow_up_questionnaire)
          respondent = finder.respondent_for(decidim_user_id: message.decidim_user_id, session_token: message.session_token)
          return false unless respondent.processable?

          notify_status_change if status_changed?
          # Respondents without email can still be tracked, so the message is saved but not emailed
          return false if respondent.email.blank?

          FollowUpQuestionnaireMessageMailer.notification(message, respondent.email, respondent.name, status_changed: status_changed?).deliver_later
          true
        end

        def notify_status_change
          return if message.decidim_user_id.blank?

          user = Decidim::User.find_by(id: message.decidim_user_id)
          return unless user

          Decidim::EventsManager.publish(
            event: "decidim.events.decidim_awesome.follow_up_questionnaire_message_status_changed",
            event_class: Decidim::DecidimAwesome::FollowUpQuestionnaireMessageStatusChangedEvent,
            resource: message,
            affected_users: [user]
          )
        end
      end
    end
  end
end
