# frozen_string_literal: true

require "decidim/dev/common_rake"
require "fileutils"

def install_module(path)
  Dir.chdir(path) do
    system("bundle exec rake decidim_decidim_awesome:install:migrations")
    system("bundle exec rake db:migrate")
  end
end

def seed_db(path)
  Dir.chdir(path) do
    system("bundle exec rake db:seed")
  end
end

def copy_themes
  FileUtils.cp_r "lib/decidim/decidim_awesome/test/themes", "spec/decidim_dummy_app/app/assets/themes", verbose: true
end

desc "copy test theme files"
task :copy_themes do
  copy_themes
end

desc "Generates a dummy app for testing"
task test_app: "decidim:generate_external_test_app" do
  ENV["RAILS_ENV"] = "test"
  install_module("spec/decidim_dummy_app")
  copy_themes
end

desc "Generates a development app."
task :development_app do
  Bundler.with_original_env do
    generate_decidim_app(
      "development_app",
      "--app_name",
      "#{base_app_name}_development_app",
      "--path",
      "..",
      "--recreate_db",
      "--demo"
    )
  end

  install_module("development_app")
  seed_db("development_app")
end
