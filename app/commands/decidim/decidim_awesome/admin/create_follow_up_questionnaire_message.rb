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
            @previous_status_id = previous_status_id_for_respondent
            create_message
            @attached_to = message
            create_attachments if process_attachments?
            notify_respondent
          end

          broadcast(:ok, message)
        end

        private

        attr_reader :form, :message, :previous_status_id

        def previous_status_id_for_respondent
          scope = Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.where(follow_up_questionnaire_id: form.follow_up_questionnaire_id)
          scope = form.decidim_user_id.present? ? scope.where(decidim_user_id: form.decidim_user_id) : scope.where(session_token: form.session_token)
          scope.order(created_at: :desc).first&.status_id
        end

        def create_message
          @message = Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.create!(
            follow_up_questionnaire_id: form.follow_up_questionnaire_id,
            status_id: form.status_id,
            body: form.body.to_s.strip.presence,
            author: selected_author,
            decidim_user_id: form.decidim_user_id,
            session_token: form.session_token
          )
        end

        def selected_author
          form.possible_authors.find { |author| author.id == form.author_id }
        end

        def status_changed?
          previous_status_id.present? && previous_status_id != message.status_id
        end

        def notify_respondent
          finder = FollowUpQuestionnaireRespondentsFinder.new(message.follow_up_questionnaire)
          respondent = finder.respondent_for(decidim_user_id: message.decidim_user_id, session_token: message.session_token)
          return unless respondent.processable?

          FollowUpQuestionnaireMessageMailer.notification(message, respondent.email, respondent.name).deliver_later if respondent.email.present?
          notify_status_change if status_changed?
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
