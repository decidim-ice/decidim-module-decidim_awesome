# frozen_string_literal: true

# Tune Proposal presenter to use markdown if configured
Decidim::Proposals::ProposalPresenter.class_eval do
  def body(links: false, extras: true, strip_tags: false, all_locales: false)
    return unless proposal

    if defined? handle_locales
      return handle_locales(proposal.body, all_locales) do |content|
        content = rendered_content(content, links, strip_tags, extras)

        if use_markdown?(proposal) && !all_locales # avoid rendering in editors
          content = render_markdown(content)
        elsif links
          content = Decidim::ContentRenderers::LinkRenderer.new(content).render
        end
        content
      end
    end

    # TODO: remove when 0.23 is ditched
    text = rendered_content(translated_attribute(proposal.body), links, strip_tags, extras)

    if use_markdown? proposal
      text = render_markdown(text)
    elsif links
      text = Decidim::ContentRenderers::LinkRenderer.new(text).render
    end
    text
  end

  private

  def rendered_content(content, links, strip_tags, extras)
    content = strip_tags(sanitize_text(content)) if strip_tags

    renderer = Decidim::ContentRenderers::HashtagRenderer.new(content)
    renderer.render(links: links, extras: extras).html_safe
  end

  def use_markdown?(proposal)
    return false unless proposal.respond_to? :organization

    config = Decidim::DecidimAwesome::Config.new(proposal.organization)
    config.context_from_component proposal
    config.enabled_for? :use_markdown_editor
  end

  def render_markdown(content)
    content = Decidim::DecidimAwesome::ContentRenderers::MarkdownRenderer.new(content).render
    # HACK: to avoid the replacement of lines to <br> that simple_format does
    content.gsub(">\n", ">").gsub("\n<", "<")
  end
end
