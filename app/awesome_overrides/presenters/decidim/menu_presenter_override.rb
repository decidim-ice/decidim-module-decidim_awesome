# frozen_string_literal: true

Decidim::MenuPresenter.class_eval do
  def evaluated_menu
    @evaluated_menu ||= Decidim::DecidimAwesome::MenuHacker.new(@name, @view)
  end
end

Decidim::MenuItemPresenter.class_eval do
  def link_to(name = nil, options = nil, html_options = nil, &block)
    html_options ||= {}
    html_options[:target] = @menu_item.try(:target)
    options ||= html_options
    @view.link_to(name, options, html_options, &block)
  end
end
