# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class FollowUpQuestionnaireMessageForm < Decidim::Form
        include Decidim::AttachmentAttributes

        attribute :follow_up_questionnaire_id, Integer
        attribute :status_id, Integer
        attribute :body, String
        attribute :author_id, Integer
        attribute :decidim_user_id, Integer
        attribute :session_token, String

        attachments_attribute :attachments

        validates :follow_up_questionnaire_id, :status_id, :author_id, presence: true, numericality: { only_integer: true }
        validate :status_belongs_to_questionnaire
        validate :respondent_present
        validate :author_is_allowed
        validate :body_or_status_change_present

        def to_params
          {
            follow_up_questionnaire_id: follow_up_questionnaire_id,
            status_id: status_id,
            body: body.to_s.strip.presence,
            author_id: author_id,
            decidim_user_id: decidim_user_id,
            session_token: session_token
          }
        end

        def error_message
          errors.full_messages.join(", ")
        end

        def possible_authors
          space = current_participatory_space
          admins = if space
                     space.user_roles(:admin).includes(:user).filter_map(&:user)
                   else
                     []
                   end
          ([current_user] + admins).compact.uniq
        end

        private

        def author_is_allowed
          return if author_id.blank?

          errors.add(:author_id, :invalid) unless possible_authors.map(&:id).include?(author_id)
        end

        def status_belongs_to_questionnaire
          return if status_id.blank? || follow_up_questionnaire_id.blank?

          status = context[:statuses_by_id]&.[](status_id)
          return if status && status.follow_up_questionnaire_id == follow_up_questionnaire_id

          errors.add(:status_id, :invalid)
        end

        def respondent_present
          errors.add(:base, :respondent_missing) if decidim_user_id.blank? && session_token.blank?
        end

        # i18n-tasks-use t('activemodel.errors.models.follow_up_questionnaire_message.attributes.body.blank_without_status_change')
        def body_or_status_change_present
          return if body.to_s.strip.present?
          return if status_id.blank? || previous_status_id.blank?
          return if status_id != previous_status_id

          errors.add(:body, :blank_without_status_change)
        end

        def previous_status_id
          return if follow_up_questionnaire_id.blank? || (decidim_user_id.blank? && session_token.blank?)

          scope = Decidim::DecidimAwesome::FollowUpQuestionnaireMessage.where(follow_up_questionnaire_id: follow_up_questionnaire_id)
          scope = decidim_user_id.present? ? scope.where(decidim_user_id: decidim_user_id) : scope.where(session_token: session_token)
          @previous_status_id ||= scope.order(created_at: :desc).first&.status_id
        end
      end
    end
  end
end
