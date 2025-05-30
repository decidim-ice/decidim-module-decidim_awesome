# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = "0.28.5"

gem "decidim", DECIDIM_VERSION
gem "decidim-decidim_awesome", path: "."
gem "decidim-templates", DECIDIM_VERSION

gem "bootsnap", "~> 1.4"

gem "puma", ">= 6.3.1"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri
  gem "rubocop-rspec", "~> 2.20.0"

  gem "decidim-dev", DECIDIM_VERSION

  gem "brakeman", "~> 5.4"
  gem "parallel_tests", "~> 4.2"
end

group :development do
  gem "letter_opener_web"
  gem "listen"
  gem "web-console"
end
