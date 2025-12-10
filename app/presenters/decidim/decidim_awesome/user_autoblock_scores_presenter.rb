# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    #
    # Decorator for users
    #
    class UserAutoblockScoresPresenter < SimpleDelegator
      class SkipItem < StandardError; end

      def scores
        @scores ||= current_rules.each_with_object({ total_score: 0 }) do |rule, calculations|
          val = rule_value(rule)
          calculations[rule_key(rule)] = val
          calculations[:total_score] += val
        end
      end

      def about_blank_detection_method(allowlist:, blocklist:)
        email_domain_detection_method(allowlist:, blocklist:, skip_with_blank_lists: false) && about.blank?
      end

      def activities_blank_detection_method(allowlist:, blocklist:)
        email_domain_detection_method(allowlist:, blocklist:, skip_with_blank_lists: false) && UserActivities.new(__getobj__).blank?
      end

      def links_in_comments_or_about_detection_method(allowlist:, blocklist:)
        email_domain_detection_method(allowlist:, blocklist:, skip_with_blank_lists: false) && (
          LinksParser.new(about).has_blocked_links? ||
          Decidim::Comments::Comment.where(author: self).any? { |comment| LinksParser.new(comment.translated_body).has_blocked_links? }
        )
      end

      def links_in_comments_or_about_with_domains_detection_method(allowlist:, blocklist:)
        LinksParser.new(about, allowlist:, blocklist:).has_blocked_links? ||
          Decidim::Comments::Comment.where(author: self).any? { |comment| LinksParser.new(comment.translated_body, allowlist:, blocklist:).has_blocked_links? }
      end

      def email_unconfirmed_detection_method(allowlist:, blocklist:)
        email_domain_detection_method(allowlist:, blocklist:, skip_with_blank_lists: false) && !confirmed?
      end

      def email_domain_detection_method(allowlist:, blocklist:, skip_with_blank_lists: true)
        return !skip_with_blank_lists if allowlist.blank? && blocklist.blank?

        email_domain = email.split("@").last

        raise SkipItem if blocklist.present? && !included_in_list?(email_domain, blocklist)
        raise SkipItem if allowlist.present? && included_in_list?(email_domain, allowlist)

        !included_in_list?(email_domain, allowlist) && (blocklist.blank? || included_in_list?(email_domain, blocklist))
      end

      private

      def included_in_list?(domain, list)
        list.any? { |name| name == domain }
      end

      def current_rules
        @current_rules ||= AwesomeConfig.find_by(var: :users_autoblocks, organization:)&.value || []
      end

      def rule_key(rule)
        [
          I18n.t(rule["type"], scope: "decidim.decidim_awesome.admin.users_autoblocks.form.types"),
          rule_lists(rule),
          rule["id"]
        ].compact_blank.join(" - ")
      end

      def rule_lists(rule)
        return if rule["allowlist"].blank? && rule["blocklist"].blank?

        scope = "decidim.decidim_awesome.admin.users_autoblocks.index.headers"
        lists = []
        lists << "#{I18n.t("allowlist", scope:)}: #{rule["allowlist"].split(/\s/).compact_blank.join(", ")}".truncate_words(10) if rule["allowlist"].present?
        lists << "#{I18n.t("blocklist", scope:)}: #{rule["blocklist"].split(/\s/).compact_blank.join(", ")}".truncate_words(10) if rule["blocklist"].present?
        return if lists.blank?

        lists.join(" | ")
      end

      def rule_value(rule)
        positive = calculate_positive(rule)

        return rule["weight"] if (rule["application_type"] == "positive" && positive) || (rule["application_type"] == "negative" && !positive)

        0
      rescue SkipItem
        0
      end

      def calculate_positive(rule)
        return if Decidim::DecidimAwesome.users_autoblocks_types.exclude?(rule["type"])
        return unless respond_to?("#{rule["type"]}_detection_method")

        allowlist = rule["allowlist"].split(/\s/).compact_blank
        blocklist = rule["blocklist"].split(/\s/).compact_blank - allowlist

        send "#{rule["type"]}_detection_method", allowlist:, blocklist:
      end

      class LinksParser
        UNWISE_REGEXP = /[{}|\\^\[\]`]/

        attr_reader :allowlist, :blocklist

        def initialize(text, allowlist: [], blocklist: [])
          @text = text
          @allowlist = allowlist
          @blocklist = blocklist - allowlist
          @sanitized_text = Rails::Html::WhiteListSanitizer.new.sanitize(text, scrubber: Decidim::Comments::UserInputScrubber.new).try(:html_safe)
        end

        def filtered_links
          @filtered_links ||= links.reject do |link|
            hostname = URI.parse(clean_link(link)).hostname

            hostname.blank? ||
              (allowlist.present? && allowlist.any? { |name| name == hostname }) ||
              (blocklist.present? && blocklist.all? { |name| name != hostname })
          end
        end

        def links
          @links ||= Nokogiri::HTML(Decidim::ContentProcessor.render(@sanitized_text)).css("a").map { |link| link["href"].presence }.compact
        end

        def has_blocked_links?
          filtered_links.present?
        end

        # This method removes characters from link producing errors trying
        # to parse them
        def clean_link(link)
          return link unless UNWISE_REGEXP.match?(link)

          link.split(UNWISE_REGEXP).first
        end
      end

      class UserActivities
        attr_reader :user, :included_activities, :registry

        def initialize(user, included_activities: [])
          @user = user
          @registry = Decidim::DecidimAwesome.user_activities_registry
          registry_keys = registry.manifests.map(&:name)
          @included_activities = included_activities.blank? ? registry_keys : registry_keys & included_activities.map(&:to_sym)
        end

        def activities
          @activities ||= included_activities.each_with_object({}) do |key, result|
            counter = registry.find(key)&.counter
            result[key] = counter.call(user) if counter
          end
        end

        def blank?
          activities.values.all?(&:zero?)
        end
      end
    end
  end
end
