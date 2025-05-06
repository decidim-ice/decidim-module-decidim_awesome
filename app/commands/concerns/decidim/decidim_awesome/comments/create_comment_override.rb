# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Comments
      module CreateCommentOverride
        extend ActiveSupport::Concern

        included do
          include ::Decidim::MultipleAttachmentsMethods

          def call
            return broadcast(:invalid) if form.invalid?

            if form.add_documents.present? && attachments_allowed?
              build_attachments
              return broadcast(:invalid) if attachments_invalid?
            end

            with_events do
              create_comment
              add_attachments
            end

            broadcast(:ok, comment)
          end

          def add_attachments
            return if form.add_documents.blank?
            return unless attachments_allowed?

            @attached_to = @comment

            build_attachments
            create_attachments
          end

          def title_for(attachment)
            return { I18n.locale => attachment[:title] } if attachment.is_a?(Hash) && attachment.has_key?(:title)

            { I18n.locale => attachment.original_filename }
          end

          def attachments_allowed?
            @attachments_allowed ||= begin
              root_commentable = root_commentable(form.commentable)
              if root_commentable.respond_to?(:component)
                awesome_config_instance.context_from_component(root_commentable.component)
              elsif root_commentable.is_a?(Decidim::Participable)
                awesome_config_instance.context_from_participatory_space(root_commentable)
              end

              awesome_config_instance.enabled_in_context?(:allow_attachments_in_comments)
            end
          end
        end
      end
    end
  end
end
