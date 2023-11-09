# frozen_string_literal: true

Rake::Task["decidim:upgrade"].enhance do
  Rake::Task["decidim_decidim_awesome:webpacker:install"].invoke
end
