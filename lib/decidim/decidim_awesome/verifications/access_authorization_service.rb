# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class AccessAuthorizationService
      def initialize(controller)
        @controller = controller
        @organization = controller.send(:current_organization)
        @group_reader = AuthorizationGroupService.new(controller)
      end

      def authorization_groups_global
        @group_reader.global_keys
      end

      def authorization_groups_contextual
        @group_reader.contextual_keys
      end

      def authorization_groups_disabled
        @group_reader.disabled_keys
      end

      def parse_handlers(value)
        @group_reader.parse_handlers(value)
      end

      def page_handlers
        hs = @controller.params[:handlers]
        return [] if hs.blank?

        Array(hs).map(&:to_s).uniq
      end

      def required_authorizations
        hs = page_handlers
        return @group_reader.adapters_for_names(@group_reader.registered_names(hs)) if hs.present?

        names = @group_reader.handlers_for(authorization_groups_global)
        @group_reader.adapters_for_names(@group_reader.registered_names(names))
      end

      def controller_requires_authorization?
        @group_reader.applicable_contextual_keys.any?
      end

      def required_authorizations_for_current_controller
        keys = @group_reader.applicable_contextual_keys
        names = @group_reader.handlers_for(keys)
        @group_reader.adapters_for_names(@group_reader.registered_names(names))
      end

      def authorization_group_handlers(key)
        @group_reader.handlers_for_key(key)
      end

      def authorization_group_adapters(key)
        names = @group_reader.registered_names(@group_reader.handlers_for_key(key))
        @group_reader.adapters_for_names(names)
      end

      def authorization_group_any_method?(key)
        @group_reader.any_method?(key)
      end

      def user_is_authorized?
        user = @controller.try(:current_user)
        return false unless user

        hs = page_handlers
        return user_authorized_for_handlers?(hs) if hs.present?

        ks = authorization_groups_global
        return false if ks.blank?

        ks.any? { |k| user_is_authorized_for_group?(k) }
      end

      def user_authorized_for_handlers?(handlers)
        user = @controller.try(:current_user)
        return false unless user

        names = Array(handlers).map(&:to_s)
        return true if names.blank?

        Decidim::Authorization.where(user:, name: names).where.not(granted_at: nil).exists?
      end

      def user_is_authorized_for_group?(key)
        user = @controller.try(:current_user)
        return false unless user

        names = @group_reader.handlers_for_key(key).map(&:to_s)
        return true if names.empty?

        if @group_reader.any_method?(key)
          Decidim::Authorization.where(user:, name: names).where.not(granted_at: nil).exists?
        else
          granted = Decidim::Authorization.where(user:, name: names).where.not(granted_at: nil).pluck(:name)
          (names - granted).empty?
        end
      end
    end
  end
end
