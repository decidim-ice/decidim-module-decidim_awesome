# frozen_string_literal: true

Decidim::User.class_eval do
  def admin
    true
  end

  def admin?
    admin
  end
end
