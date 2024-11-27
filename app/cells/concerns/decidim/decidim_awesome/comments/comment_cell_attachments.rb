# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Comments
      module CommentCellAttachments
        extend ActiveSupport::Concern

        included do
          private

          alias_method :decidim_original_cache_hash, :cache_hash

          def cache_hash
            extra_hash = attachments_allowed? ? 1 : 0
            "#{decidim_original_cache_hash}#{Decidim.cache_key_separator}#{extra_hash}"
          end

          def attachments_allowed?
            @attachments_allowed ||= begin
              if model.respond_to?(:component)
                awesome_config_instance.context_from_component(model.component)
              elsif model.is_a?(Decidim::Participable)
                awesome_config_instance.context_from_participatory_space(model)
              else
                awesome_config_instance.context_from_request(request)
              end

              awesome_config_instance.enabled_in_context?(:allow_attachments_in_comments)
            end
          end
        end
      end
    end
  end
end
