# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = "0.27.9"

gem "decidim", DECIDIM_VERSION
# this causes failures if not enabled (check if still necessary in the future)
gem "decidim-decidim_awesome", path: "."
gem "decidim-templates", DECIDIM_VERSION

gem "bootsnap", "~> 1.4"

gem "puma", ">= 5.5.1"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console"
end

group :test do
  gem "codecov", require: false
end