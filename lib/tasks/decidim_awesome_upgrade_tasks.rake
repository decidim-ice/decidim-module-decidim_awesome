# frozen_string_literal: true

Rake::Task["decidim:webpacker:install"].enhance do
  Rake::Task["decidim_decidim_awesome:webpacker:install"].invoke
end

Rake::Task["decidim:choose_target_plugins"].enhance do
  ENV["FROM"] = "#{ENV.fetch("FROM", nil)},decidim_decidim_awesome"
end

Rake::Task["decidim:webpacker:upgrade"].enhance do
  Rake::Task["decidim_decidim_awesome:webpacker:install"].invoke
end
