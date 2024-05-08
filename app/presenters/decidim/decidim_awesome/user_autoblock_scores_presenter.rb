# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    #
    # Decorator for users
    #
    class UserAutoblockScoresPresenter < SimpleDelegator
      def scores
        @scores ||= current_rules.each_with_object({ total: 0 }) do |rule, calculations|
          val = rule_value(rule)
          calculations[rule_key(rule)] = val
          calculations[:total] += val
        end
      end

      private

      def current_rules
        @current_rules ||= (AwesomeConfig.find_by(var: :users_autoblocks, organization:)&.value || [])
      end

      def rule_key(rule)
        [
          I18n.t(rule["type"], scope: "decidim.decidim_awesome.admin.users_autoblocks.form.types"),
          rule["id"]
        ].join(" - ")
      end

      def rule_value(rule)
        return 0 unless rule["enabled"]

        positive = calculate_positive(rule)
        return rule["weight"] if (rule["blocklist"] && positive) || (!rule["blocklist"] && !positive)

        0
      end

      def calculate_positive(rule)
        # TODO: Pending blank activities type
        case rule["type"]
        when "about_blank"
          about.blank?
        when "links_in_comments_or_about"
          LinksParser.new(about).has_blocked_links? ||
            Decidim::Comments::Comment.where(author: self).any? { |comment| LinksParser.new(comment.translated_body).has_blocked_links? }
        when "email_unconfirmed"
          !confirmed?
        when "email_domain"
          email_domain = email.split("@").last
          domains = rule["variable"].split(/\s/).compact_blank
          email_domain.present? && domains.any? { |name| name == email_domain }
        end
      end

      class LinksParser
        def initialize(text, allowlist: [], blocklist: [])
          @text = text
          @allowlist = allowlist
          @blocklist = blocklist - allowlist
          @sanitized_text = Rails::Html::WhiteListSanitizer.new.sanitize(text, scrubber: Decidim::Comments::UserInputScrubber.new).try(:html_safe)
        end

        def filtered_links
          @filtered_links ||= links.reject do |link|
            hostname = URI.parse(link).hostname
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
      end
    end
  end
end
