# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      ##
      # Override Proposal Presenter to access private field.
      module ProposalPresenterOverride
        extend ActiveSupport::Concern
        included do
          def private_body(links: false, extras: true, strip_tags: false, all_locales: false)
            return unless proposal
            content_handle_locale(proposal.private_body, all_locales, extras, links, strip_tags)
          end
        end
      end
    end
  end
end
