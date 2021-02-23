# frozen_string_literal: true

Decidim::MenuPresenter.class_eval do
  def evaluated_menu
    @evaluated_menu ||= if Decidim::DecidimAwesome.config.send(@name) == :disabled
                          begin
                            menu = Menu.new(@name)
                            menu.build_for(@view)
                            menu
                          end
                        else
                          Decidim::DecidimAwesome::MenuHacker.new(@name, @view)
                        end
  end
end

Decidim::MenuItemPresenter.class_eval do
  def link_to(name = nil, options = nil, html_options = nil, &block)
    html_options ||= {}
    html_options[:target] = @menu_item.try(:target)

    options ||= html_options
    @view.link_to(name, options, html_options, &block)
  end

  def active
    return @menu_item.active.call(url, @view) if @menu_item.try(:active).respond_to?(:call)

    @menu_item&.active
  end
end
