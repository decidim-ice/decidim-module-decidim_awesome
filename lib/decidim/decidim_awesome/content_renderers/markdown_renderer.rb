# frozen_string_literal: true

require "redcarpet"

module Decidim
  module DecidimAwesome
    module ContentRenderers
      # A renderer that processes markdown
      class MarkdownRenderer < Decidim::ContentRenderers::BaseRenderer
        # @return [String] the content ready to display (contains HTML)
        def render(options = { filter_html: true, autolink: true, no_intra_emphasis: true, fenced_code_blocks: true, disable_indented_code_blocks: true, tables: true })
          md = Redcarpet::Markdown.new(Redcarpet::Render::HTML, options).render(content)
          "<div class=\"awesome-markdown--proposals\">#{md}</div>"
        end
      end
    end
  end
end
