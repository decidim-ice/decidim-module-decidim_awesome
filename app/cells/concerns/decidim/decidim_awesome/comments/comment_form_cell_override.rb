# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Comments
      module CommentFormCellOverride
        extend ActiveSupport::Concern

        included do
          include CommentCellAttachments

          alias_method :decidim_original_comment_as_for, :comment_as_for

          def comment_as_for(form)
            render view: :extended_comment_as, locals: { form: }
          end
        end
      end
    end
  end
end
