# frozen_string_literal: true

require "decidim/decidim_awesome/content_renderers/markdown_renderer"

# Tune Proposal presenter to use markdown if configured
Decidim::Proposals::ProposalPresenter.class_eval do
  def body(links: false, extras: true, strip_tags: false)
    text = proposal.body
    text = strip_tags(text) if strip_tags

    renderer = Decidim::ContentRenderers::HashtagRenderer.new(text)
    text = renderer.render(links: links, extras: extras).html_safe

    if use_markdown? proposal
      # HACK: to avoid the replacement of lines to <br> that simple_format does
      text = Decidim::DecidimAwesome::ContentRenderers::MarkdownRenderer.new(text).render
      text = text.gsub(">\n", ">").gsub("\n<", "<")
    elsif links
      text = Decidim::ContentRenderers::LinkRenderer.new(text).render
    end
    text
  end

  def use_markdown?(proposal)
    return false unless proposal.respond_to? :organization

    config = Decidim::DecidimAwesome::AwesomeConfig.config_for(proposal.organization)
    config[:use_markdown_in_proposals]
  end
end
