# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module AdminLog
      module ComponentPresenterOverride
        extend ActiveSupport::Concern

        included do
          alias_method :decidim_original_action_string, :action_string
          alias_method :decidim_original_i18n_params, :i18n_params

          def action_string
            return "decidim.decidim_awesome.admin_log.component.#{action}" if action == "destroy_private_data"

            decidim_original_action_string
          end

          def i18n_params
            return decidim_original_i18n_params unless action == "destroy_private_data"

            decidim_original_i18n_params.merge({ count: action_log.extra["count"] })
          end
        end
      end
    end
  end
end
