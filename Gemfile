# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# Inside the development app, the relative require has to be one level up, as
# the Gemfile is copied to the development_app folder (almost) as is.
base_path = "."
base_path = ".." if File.basename(__dir__) == "development_app"
base_path = "../.." if File.basename(__dir__) == "decidim_dummy_app"
# We need absolutes routes to be able to use this Gemfile in Appraisal
require "#{File.realpath base_path}/lib/decidim/decidim_awesome/version"

gem "decidim", Decidim::DecidimAwesome::DECIDIM_VERSION
gem "decidim-decidim_awesome", path: "."

gem "bootsnap", "~> 1.4"
gem "puma", ">= 4.3"
gem "uglifier", "~> 4.1"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", Decidim::DecidimAwesome::DECIDIM_VERSION
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
