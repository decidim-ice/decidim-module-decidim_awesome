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
        case rule["type"]
        when "about_blank"
          about.blank?
        when "activities_blank"
          UserActivities.new(__getobj__).blank?
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
