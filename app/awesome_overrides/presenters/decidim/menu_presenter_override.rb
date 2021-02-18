# frozen_string_literal: true

Decidim::MenuPresenter.class_eval do
  def evaluated_menu
    @evaluated_menu ||= Decidim::DecidimAwesome::MenuHacker.new(@name, @view.current_organization, @view)
  end
end
