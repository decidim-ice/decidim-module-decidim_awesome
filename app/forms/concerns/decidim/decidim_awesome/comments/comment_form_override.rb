# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Comments
      module CommentFormOverride
        extend ActiveSupport::Concern

        included do
          include Decidim::AttachmentAttributes

          attribute :attachment, AttachmentForm

          attachments_attribute :documents
        end
      end
    end
  end
end
