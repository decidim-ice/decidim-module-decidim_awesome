# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class MenuHacker
      include Decidim::TranslatableAttributes

      def initialize(name, view)
        @name = name
        @organization = view.try(:current_organization)
        @user = view.try(:current_user)
        @view = view
      end

      # returns a combined array of the Decidim defined menu and the hacked stored as config vars
      def items(include_invisible: false)
        return @items if @items

        @items = default_items
        menu_overrides.each do |item|
          default = default_items.find { |i| i.url.gsub(/\?.*/, "") == item.url }
          if default
            item.send("overrided?=", true)
            @items.reject! { |i| i.url.gsub(/\?.*/, "") == item.url }
          end
          @items << item
        end

        @items.select!(&:visible?) unless include_invisible
        @items.sort_by!(&:position)
      end

      private

      attr_accessor :organization, :user
      attr_reader :name, :view

      def default_items
        @default_items ||= build_menu.instance_variable_get(:@items).map do |item|
          item.instance_variable_set(:@active, method(:activate?)) unless item.active == :exact
          item
        end
      end

      def build_menu
        menu = Decidim::Menu.new(name)
        menu.build_for(view)
        menu
      end

      # rubocop:disable Style/OpenStructUse
      def menu_overrides
        @menu_overrides ||= current_config.map do |item|
          OpenStruct.new(
            label: translated_attribute(item["label"], organization),
            raw_label: item["label"],
            url: item["url"],
            position: item["position"] || 1,
            # see options in https://github.com/comfy/active_link_to
            active: method(:activate?),
            visibility: item["visibility"],
            visible?: visible?(item),
            target: item["target"],
            overrided?: false
          )
        end
      end
      # rubocop:enable Style/OpenStructUse

      def activate?(url, view)
        urls = @items.map(&:url).sort_by(&:length).reverse
        url == urls.find { |u| view.request.original_fullpath.start_with?(u) }
      end

      def visible?(item)
        case item["visibility"]
        when "hidden"
          false
        when "logged"
          user.present?
        when "non_logged"
          user.blank?
        when "verified_user"
          # the cleaner version should be user.authorizations.any?
          # but there is not relationship between users and authorizations
          Decidim::Authorization.where(user: user).any? { |auth| auth.granted? && !auth.expired? }
        else
          true
        end
      end

      def current_config
        @current_config ||= (AwesomeConfig.find_by(var: name, organization: organization)&.value || []).filter { |i| i.is_a? Hash }
      end
    end
  end
end
