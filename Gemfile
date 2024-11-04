# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = "0.28.4"

gem "decidim", DECIDIM_VERSION
# this causes failures if not enabled (check if still necessary in the future)
gem "decidim-decidim_awesome", path: "."
gem "decidim-templates", DECIDIM_VERSION

gem "bootsnap", "~> 1.4"

gem "puma", ">= 6.3.1"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION

  gem "brakeman", "~> 5.4"
  gem "net-imap", "~> 0.2.3"
  gem "net-pop", "~> 0.1.1"
  gem "net-smtp", "~> 0.3.1"
  gem "parallel_tests", "~> 4.2"
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 4.2"
end
