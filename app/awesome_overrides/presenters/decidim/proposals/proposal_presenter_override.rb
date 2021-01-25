# frozen_string_literal: true

# Tune Proposal presenter to use markdown if configured
Decidim::Proposals::ProposalPresenter.class_eval do
  def body(links: false, extras: true, strip_tags: false, all_locales: false)
    return unless proposal

    handle_locales(proposal.body, all_locales) do |content|
      content = strip_tags(sanitize_text(content)) if strip_tags

      renderer = Decidim::ContentRenderers::HashtagRenderer.new(content)
      content = renderer.render(links: links, extras: extras).html_safe

      if use_markdown? proposal
        content = Decidim::DecidimAwesome::ContentRenderers::MarkdownRenderer.new(content).render
        # HACK: to avoid the replacement of lines to <br> that simple_format does
        content = content.gsub(">\n", ">").gsub("\n<", "<")
      elsif links
        content = Decidim::ContentRenderers::LinkRenderer.new(content).render if links
      end
      content
    end
  end

  private

  def use_markdown?(proposal)
    return false unless proposal.respond_to? :organization

    config = Decidim::DecidimAwesome::Config.new(proposal.organization)
    config.context_from_component proposal
    config.enabled_for? :use_markdown_editor
  end
end
