# frozen_string_literal: true

Decidim::User.class_eval do
  # TODO: Assign admin if is in a constraint
  def admin
    false
  end

  def admin?
    admin
  end
end
