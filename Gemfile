# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = "0.29.3"

gem "decidim", DECIDIM_VERSION
gem "decidim-decidim_awesome", path: "."
gem "decidim-templates", DECIDIM_VERSION

gem "bootsnap", "~> 1.4"

gem "puma", ">= 6.3.1"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION

  gem "brakeman", "~> 6.1"
  gem "net-imap", "~> 0.4.16"
  gem "net-pop", "~> 0.1.2"
  gem "net-smtp", "~> 0.3.1"
  gem "parallel_tests", "~> 4.2"
  gem "rubocop-rspec", "~> 3.3.0"
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "web-console", "~> 4.2"
end
