# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Comments
      module CommentCellOverride
        extend ActiveSupport::Concern

        included do
          include Decidim::AttachmentsHelper
          include CommentCellAttachments

          alias_method :decidim_original_comment_body, :comment_body

          def comment_body
            return render :body_with_attachments if current_user.present?

            decidim_original_comment_body
          end

          private

          def tab_panel_items
            attachments_tab_panel_items(model).map do |panel|
              panel[:id] = "#{panel[:id]}-comment-#{model.id}"
              panel
            end
          end
        end
      end
    end
  end
end
