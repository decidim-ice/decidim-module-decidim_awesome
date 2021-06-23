# frozen_string_literal: true

Decidim::User.class_eval do
  # TODO: Assign admin if is a constraint exists for the current_context
  # TODO: add a middleware to store the current context
  def admin
    # no context available, return default attribute
    read_attribute("admin")
  end

  def admin?
    admin.present?
  end
end
