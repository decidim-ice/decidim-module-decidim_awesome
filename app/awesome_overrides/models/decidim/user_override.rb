# frozen_string_literal: true

Decidim::User.class_eval do
  # TODO: Assign admin if is a constraint exists for the current_context
  # TODO: add a middleware to store the current context
  def admin
    return read_attribute("admin") if read_attribute("admin")

    # no context available, return default attribute
    read_attribute("admin")
  end

  def admin?
    admin.present?
  end

  def awesome_admin_scopes; end
end
