# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION
# DECIDIM_VERSION =  { git: "https://github.com/decidim/decidim" }
DECIDIM_VERSION = "0.21"

gem "decidim", DECIDIM_VERSION
gem "decidim-decidim_awesome", path: "."

gem "bootsnap", "~> 1.4"
gem "puma", ">= 4.3"
gem "uglifier", "~> 4.1"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "faker", "~> 1.9"
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end

group :test do
  gem "appraisal"
  gem "codecov", require: false
end
