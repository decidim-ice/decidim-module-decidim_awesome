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

Rake::Task["decidim_decidim_awesome:install:migrations"].enhance do
  Rake::Task["decidim_decidim_awesome:upgrade:migrate_awesome_map_menu_categories_to_menu_taxonomies"].invoke
end
