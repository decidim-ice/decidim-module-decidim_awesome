# frozen_string_literal: true

Rake::Task["decidim:webpacker:install"].enhance do
  Rake::Task["decidim_decidim_awesome:webpacker:install"].invoke
end

Rake::Task["decidim:choose_target_plugins"].enhance do
  unless ENV["FROM"].to_s.include?("decidim_decidim_awesome")
    ENV["FROM"] = "#{ENV.fetch("FROM", nil)},decidim_decidim_awesome"
    ENV["FROM"] = "#{ENV.fetch("FROM", nil)},active_hashcash" if Decidim::DecidimAwesome.enabled?(:hashcash_signup, :hashcash_login)
  end
end

Rake::Task["decidim:webpacker:upgrade"].enhance do
  Rake::Task["decidim_decidim_awesome:webpacker:install"].invoke
end
