# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module AdminLog
      module UserPresenterOverride
        extend ActiveSupport::Concern

        included do
          alias_method :decidim_original_action_string, :action_string
          alias_method :decidim_original_i18n_params, :i18n_params
          alias_method :decidim_original_resource_presenter, :resource_presenter

          def action_string
            return "decidim.decidim_awesome.admin_log.user.#{action}" if authorization_action?

            decidim_original_action_string
          end

          def i18n_params
            return decidim_original_i18n_params unless authorization_action?

            decidim_original_i18n_params.merge({ handler_name: h.content_tag(:span, action_log.extra["handler_name"], class: "logs__log__resource") })
          end

          def resource_presenter
            return decidim_original_resource_presenter unless authorization_action? && authorization_user

            @resource_presenter ||= Decidim::Log::UserPresenter.new(authorization_user, h, { "name" => authorization_user.name, "nickname" => authorization_user.nickname })
          end

          def authorization_user
            @authorization_user ||= Decidim::User.find_by(id: action_log.extra["user_id"])
          end

          def authorization_action?
            action.in?(%w(admin_creates_authorization admin_forces_authorization admin_destroys_authorization))
          end
        end
      end
    end
  end
end
