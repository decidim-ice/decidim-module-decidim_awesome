# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class MenuHacker
      include Decidim::TranslatableAttributes
      include Decidim::Routes::LocaleRedirects

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
          default = default_items.find { |i| same_url?(i.url.gsub(/\?.*/, ""), item.url) }
          if default
            item.send("overridden?=", true)
            item[:original_active] = default.active
            @items.reject! { |i| same_url?(i.url.gsub(/\?.*/, ""), item.url) }
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
        @default_items ||= build_menu.items
      end

      def build_menu
        menu = Decidim::Menu.new(name)
        menu.build_for(view)
        menu
      end

      def menu_overrides
        @menu_overrides ||= current_config.map do |item|
          OpenStruct.new(
            label: translated_attribute(item["label"], organization),
            raw_label: item["label"],
            url: localized_url(item["url"]),
            raw_url: item["url"],
            position: item["position"] || 1,
            # see options in https://github.com/comfy/active_link_to
            active: method(:activate?),
            visibility: item["visibility"],
            visible?: visible?(item),
            target: item["target"],
            overridden?: false
          )
        end
      end

      def activate?(url, view)
        current_path = strip_locale(view.request.original_fullpath)
        urls = @items.map(&:url).sort_by { |u| strip_locale(u).length }.reverse
        url == urls.find { |u| current_path.start_with?(strip_locale(u)) }
      end

      # Renders local paths with the current locale prefix, external urls untouched
      def localized_url(url)
        return url if url.blank? || !url.start_with?("/")

        append_locale(strip_locale(url), I18n.locale)
      end

      # menu urls are compared ignoring the locale prefix
      def same_url?(first, second)
        strip_locale(first) == strip_locale(second)
      end

      def strip_locale(url)
        ContextAnalyzers::RequestAnalyzer.strip_locale(url)
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
          Decidim::Authorization.where(user:).any? { |auth| auth.granted? && !auth.expired? }
        else
          true
        end
      end

      def current_config
        @current_config ||= (AwesomeConfig.find_by(var: name, organization:)&.value || []).grep(Hash)
      end
    end
  end
end
