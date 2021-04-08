# frozen_string_literal: true

# Tune Proposal presenter to use markdown if configured
Decidim::Proposals::ProposalPresenter.class_eval do
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def body(links: false, extras: true, strip_tags: false, all_locales: false)
    return unless proposal

    if defined? handle_locales
      return handle_locales(proposal.body, all_locales) do |content|
        content = strip_tags(sanitize_text(content)) if strip_tags

        renderer = Decidim::ContentRenderers::HashtagRenderer.new(content)
        content = renderer.render(links: links, extras: extras).html_safe

        if use_markdown?(proposal) && !all_locales # avoid rendering in editors
          content = render_markdown(content)
        elsif links
          content = Decidim::ContentRenderers::LinkRenderer.new(content).render
        end
        content
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

    # TODO: remove when 0.23 is ditched
    text = translated_attribute(proposal.body)
    text = strip_tags(sanitize_text(text)) if strip_tags

    renderer = Decidim::ContentRenderers::HashtagRenderer.new(text)
    text = renderer.render(links: links, extras: extras).html_safe

    if use_markdown? proposal
      text = render_markdown(text)
    elsif links
      text = Decidim::ContentRenderers::LinkRenderer.new(text).render
    end
    text
  end

  private

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
