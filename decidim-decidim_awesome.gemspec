# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/decidim_awesome/version"

Gem::Specification.new do |s|
  s.version = Decidim::DecidimAwesome::VERSION
  s.authors = ["Ivan Vergés"]
  s.email = ["ivan@platoniq.net"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/platoniq/decidim-module-decidim_awesome"
  # rubocop:disable Gemspec/RequiredRubyVersion
  s.required_ruby_version = ">= 2.7"
  # rubocop:enable Gemspec/RequiredRubyVersion

  s.name = "decidim-decidim_awesome"
  s.summary = "A decidim decidim_awesome module"
  s.description = "Some usability and UX tweaks for Decidim."

  s.files = Dir["{app,config,lib,vendor,db}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "package.json", "README.md", "CHANGELOG.md"]

  s.add_dependency "decidim-admin", Decidim::DecidimAwesome::COMPAT_DECIDIM_VERSION
  s.add_dependency "decidim-core", Decidim::DecidimAwesome::COMPAT_DECIDIM_VERSION
  s.add_dependency "sassc", "~> 2.3" # TODO: check if this can be removed

  s.add_development_dependency "appraisal"
  s.add_development_dependency "decidim-dev", Decidim::DecidimAwesome::COMPAT_DECIDIM_VERSION
  s.metadata["rubygems_mfa_required"] = "true"
end
