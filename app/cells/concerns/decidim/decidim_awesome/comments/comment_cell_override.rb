# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Comments
      module CommentCellOverride
        extend ActiveSupport::Concern

        included do
          include Decidim::AttachmentsHelper

          alias_method :decidim_original_votes, :votes

          def votes
            return render :votes_with_attachments if current_user.present?

            decidim_original_votes
          end
        end
      end
    end
  end
end
