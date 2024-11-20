# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Comments
      module CommentFormCellOverride
        extend ActiveSupport::Concern

        included do
          alias_method :decidim_original_comment_as_for, :comment_as_for

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

          def comment_as_for(form)
            render view: :extended_comment_as, locals: { form: }
          end
        end
      end
    end
  end
end
