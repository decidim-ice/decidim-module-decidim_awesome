# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # Removes the extra tags of the HTML code editor from the content sent through the public site,
    # as Decidim displays some content written by participants with the rules for admins.
    module StripHtmlCodeEditorTags
      extend ActiveSupport::Concern

      included do
        before_action :strip_html_code_editor_tags, unless: -> { request.get? }
      end

      private

      def strip_html_code_editor_tags
        return unless helpers.html_code_editor_in_use?

        tags = Decidim::DecidimAwesome.html_code_editor_allowed_tags.map(&:to_s)
        without_html_code_editor_tags(params, tags) if tags.any?
      end

      def without_html_code_editor_tags(value, tags)
        case value
        when ActionController::Parameters then value.each_pair { |key, nested| value[key] = without_html_code_editor_tags(nested, tags) }
        when Array then value.map { |nested| without_html_code_editor_tags(nested, tags) }
        when String then unwrap_html_code_editor_tags(value, tags)
        else value
        end
      end

      # The content is parsed only when it has one of the tags, the rest is left as it was sent
      def unwrap_html_code_editor_tags(html, tags)
        return html unless tags.any? { |tag| html.match?(/<#{Regexp.escape(tag)}/i) }

        scrubber = Loofah::Scrubber.new(direction: :bottom_up) { |node| node.replace(node.children) if tags.include?(node.name) }
        Loofah.fragment(html).scrub!(scrubber).to_s
      end
    end
  end
end
