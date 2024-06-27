# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")

Decidim::Webpacker.register_entrypoints(
  # override the Decidim entry point for decidim so we can define a custom createEditor method
  decidim_editor: "#{base_path}/app/packs/entrypoints/decidim_editor.js",
  decidim_decidim_awesome: "#{base_path}/app/packs/entrypoints/decidim_decidim_awesome.js",
  decidim_admin_decidim_awesome: "#{base_path}/app/packs/entrypoints/decidim_admin_decidim_awesome.js",
  decidim_admin_decidim_awesome_global: "#{base_path}/app/packs/entrypoints/decidim_admin_decidim_awesome_global.js",
  decidim_decidim_awesome_map: "#{base_path}/app/packs/entrypoints/decidim_decidim_awesome_map.js",
  decidim_decidim_awesome_custom_fields: "#{base_path}/app/packs/entrypoints/decidim_decidim_awesome_custom_fields.js",
  decidim_decidim_awesome_iframe: "#{base_path}/app/packs/entrypoints/decidim_decidim_awesome_iframe.scss"
)
