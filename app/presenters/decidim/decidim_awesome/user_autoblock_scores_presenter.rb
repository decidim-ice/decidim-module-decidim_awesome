# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    #
    # Decorator for users
    #
    class UserAutoblockScoresPresenter < SimpleDelegator
      USERS_AUTOBLOCKS_TYPES = {
        "about_blank" => { has_variable: false, default_blocklist: true },
        "activities_blank" => { has_variable: false, default_blocklist: true },
        "links_in_comments_or_about" => { has_variable: true, default_blocklist: true },
        "email_unconfirmed" => { has_variable: true, default_blocklist: true },
        "email_domain" => { has_variable: true, default_blocklist: true }
      }.freeze

      def scores
        @scores ||= current_rules.each_with_object({ total_score: 0 }) do |rule, calculations|
          val = rule_value(rule)
          calculations[rule_key(rule)] = val
          calculations[:total_score] += val
        end
      end

      def about_blank_detection_method(allowlist:, blocklist:)
        email_domain_detection_method(allowlist:, blocklist:) && about.blank?
      end

      def activities_blank_detection_method(allowlist:, blocklist:)
        email_domain_detection_method(allowlist:, blocklist:) && UserActivities.new(__getobj__).blank?
      end

      def links_in_comments_or_about_detection_method(allowlist:, blocklist:)
        LinksParser.new(about, allowlist:, blocklist:).has_blocked_links? ||
          Decidim::Comments::Comment.where(author: self).any? { |comment| LinksParser.new(comment.translated_body, allowlist:, blocklist:).has_blocked_links? }
      end

      def email_unconfirmed_detection_method(allowlist:, blocklist:)
        email_domain_detection_method(allowlist:, blocklist:) && !confirmed?
      end

      def email_domain_detection_method(allowlist:, blocklist:)
        email_domain = email.split("@").last
        email_domain.blank? ||
          (allowlist.present? && allowlist.all? { |name| name != email_domain }) ||
          (blocklist.present? && blocklist.any? { |name| name == email_domain })
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
        positive = calculate_positive(rule)

        return rule["weight"] if (rule["application_type"] == "positive" && positive) || (rule["application_type"] == "negative" && !positive)

        0
      end

      def calculate_positive(rule)
        return if USERS_AUTOBLOCKS_TYPES.keys.exclude?(rule["type"])
        return unless respond_to?("#{rule["type"]}_detection_method")

        allowlist = rule["allowlist"].split(/\s/).compact_blank
        blocklist = rule["blocklist"].split(/\s/).compact_blank - allowlist

        send "#{rule["type"]}_detection_method", allowlist:, blocklist:
      end

      class LinksParser
        attr_reader :allowlist, :blocklist

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

      class UserActivities
        DEFAULT_ACTIVITIES = {
          comments: ->(user) { Decidim::Comments::Comment.where(author: user).count },
          comment_votes: ->(user) { Decidim::Comments::CommentVote.where(author: user).count },
          proposals: ->(user) { Decidim::Proposals::Proposal.coauthored_by(user).count },
          proposals_votes: ->(user) { Decidim::Proposals::ProposalVote.where(author: user).where(author: user).count },
          collaborative_drafts: ->(user) { Decidim::Proposals::CollaborativeDraft.coauthored_by(user).count },
          amendments: ->(user) { Decidim::Amendment.where(amender: user).count },
          debates: ->(user) { Decidim::Debates::Debate.where(author: user).count },
          initiatives: ->(user) { Decidim::Initiative.where(author: user).count },
          initiatives_votes: ->(user) { Decidim::InitiativesVote.where(author: user).count },
          meetings: ->(user) { Decidim::Meetings::Meeting.where(author: user).count },
          meetings_answers: ->(user) { Decidim::Meetings::Answer.where(user:).count },
          budgets_orders: ->(user) { Decidim::Budgets::Order.where(user:).count },
          forms_answers: ->(user) { Decidim::Forms::Answer.where(user:).count },
          blog_posts: ->(user) { Decidim::Blogs::Post.where(author: user).count },
          follows: ->(user) { Decidim::Follow.where(user:).count },
          endorsements: ->(user) { Decidim::Endorsement.where(author: user).count },
          reports: ->(user) { Decidim::Report.where(user:).count }
        }.freeze

        attr_reader :user, :included_activities

        def self.available_keys
          @available_keys ||= begin
            keys = [:reports, :endorsements, :follows, :forms_answers, :amendments]
            keys += [:comments, :comments_votes] if Decidim.module_installed?(:comments)
            keys += [:proposals, :proposals_votes, :collaborative_drafts] if Decidim.module_installed?(:proposals)
            keys += [:debates] if Decidim.module_installed?(:debates)
            keys += [:initiatives, :initiatives_votes] if Decidim.module_installed?(:initiatives)
            keys += [:meetings, :meetings_answers] if Decidim.module_installed?(:meetings)
            keys += [:budgets_orders] if Decidim.module_installed?(:budgets)
            keys += [:blog_posts] if Decidim.module_installed?(:blogs)
            keys
          end
        end

        def initialize(user, included_activities: [])
          @user = user
          @included_activities = included_activities.blank? ? self.class.available_keys : self.class.available_keys & included_activities
        end

        def activities
          @activities = DEFAULT_ACTIVITIES.slice(*included_activities).transform_values { |method| method.call(user) }
        end

        def blank?
          activities.values.all?(&:zero?)
        end
      end
    end
  end
end
