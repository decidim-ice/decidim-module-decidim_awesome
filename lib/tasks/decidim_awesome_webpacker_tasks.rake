# frozen_string_literal: true

require "decidim/gem_manager"

namespace :decidim_decidim_awesome do
  namespace :webpacker do
    desc "Installs Decidim Awesome webpacker files in Rails instance application"
    task install: :environment do
      raise "Decidim gem is not installed" if decidim_path.nil?

      # Ovewrite JS custom config file
      copy_awesome_file_to_application "lib/decidim/webpacker/webpack/custom.js", "config/webpack/custom.js"
    end

    def decidim_awesome_path
      @decidim_awesome_path ||= Pathname.new(decidim_awesome_gemspec.full_gem_path) if Gem.loaded_specs.has_key?(gem_name)
    end

    def decidim_awesome_gemspec
      @decidim_awesome_gemspec ||= Gem.loaded_specs[gem_name]
    end

    def rails_app_path
      @rails_app_path ||= Rails.root
    end

    def copy_awesome_file_to_application(origin_path, destination_path = origin_path)
      FileUtils.cp(decidim_awesome_path.join(origin_path), rails_app_path.join(destination_path))
    end

    def system!(command)
      system("cd #{rails_app_path} && #{command}") || abort("\n== Command #{command} failed ==")
    end

    def gem_name
      "decidim-decidim_awesome"
    end
  end
end
