# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      module ProposalPresenterOverride
        extend ActiveSupport::Concern
        included do
          def private_body(links: false, extras: true, strip_tags: false, all_locales: false)
            return unless proposal

            handle_locales(proposal.private_body, all_locales) do |content|
              content = strip_tags(sanitize_text(content)) if strip_tags
              renderer = Decidim::ContentRenderers::HashtagRenderer.new(content)
              content = renderer.render(links: links, extras: extras).html_safe
              
              content = Decidim::ContentRenderers::LinkRenderer.new(content).render if links
              content
            end

          end
        end
      end
    end
  end
end