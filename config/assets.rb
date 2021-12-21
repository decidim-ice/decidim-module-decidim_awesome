# frozen_string_literal: true
# This file is located at `config/assets.rb` of your module.

# Define the base path of your module. Please note that `Rails.root` may not be
# used because we are not inside the Rails environment when this file is loaded.
base_path = File.expand_path("..", __dir__)

# Register an additional load path for webpack. All the assets within these
# directories will be available for inclusion within the Decidim assets. For
# example, if you have `app/packs/src/decidim/foo.js`, you can include that file
# in your JavaScript entrypoints (or other JavaScript files within Decidim)
# using `import "src/decidim/foo"` after you have registered the additional path
# as follows.
Decidim::Webpacker.register_path("#{base_path}/app/packs")

# Register the entrypoints for your module. These entrypoints can be included
# within your application using `javascript_pack_tag` and if you include any
# SCSS files within the entrypoints, they become available for inclusion using
# `stylesheet_pack_tag`.
Decidim::Webpacker.register_entrypoints(
  decidim_decidim_awesome: "#{base_path}/app/packs/entrypoints/decidim_decidim_awesome.js",
  decidim_admin_decidim_awesome: "#{base_path}/app/packs/entrypoints/decidim_admin_decidim_awesome.js",
  decidim_decidim_awesome_map: "#{base_path}/app/packs/entrypoints/decidim_decidim_awesome_map.js",
  decidim_decidim_awesome_load_map: "#{base_path}/app/packs/entrypoints/decidim_decidim_awesome_load_map.js",
  decidim_decidim_awesome_proposals_custom_fields: "#{base_path}/app/packs/entrypoints/decidim_decidim_awesome_proposals_custom_fields.js",
  decidim_decidim_awesome_admin_form_exit_warn: "#{base_path}/app/packs/entrypoints/decidim_decidim_awesome_admin_form_exit_warn.js",
  decidim_decidim_awesome_iframe: "#{base_path}/app/packs/entrypoints/decidim_decidim_awesome_iframe.scss"
)

# If you want to import some extra SCSS files in the Decidim main SCSS file
# without adding any extra stylesheet inclusion tags, you can use the following
# method to register the stylesheet import for the main application.
# Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/decidim_awesome/awesome_application")

# If you want to do the same but include the SCSS file for the admin panel's
# main SCSS file, you can use the following method.
# Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/foo/admin", group: :admin)

# If you want to override some SCSS variables/settings for Foundation from the
# module, you can add the following registered import.
# Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/foo/settings", type: :settings)

# If you want to do the same but override the SCSS variables of the admin
# panel's styles, you can use the following method.
# Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/foo/admin_settings", type: :settings, group: :admin)
