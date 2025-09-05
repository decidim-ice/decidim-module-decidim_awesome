# frozen_string_literal: true

namespace :decidim_decidim_awesome do
  namespace :upgrade do
    desc "Migrate menu_categories to menu_taxonomies in awesome_map components"
    task migrate_awesome_map_menu_categories_to_menu_taxonomies: :environment do
      components_to_migrate = Decidim::Component.where(manifest_name: "awesome_map")
                                                .where("settings->'global' ? 'menu_categories'")

      next if components_to_migrate.empty?

      puts "Starting migration of menu_categories to menu_taxonomies in awesome_map components..."
      puts "Found #{components_to_migrate.count} components to migrate."

      updated_count = 0

      components_to_migrate.find_each do |component|
        raw_settings = component.read_attribute(:settings)

        if raw_settings&.dig("global")&.has_key?("menu_categories")
          menu_categories_value = raw_settings["global"]["menu_categories"]

          raw_settings["global"].delete("menu_categories")
          raw_settings["global"]["menu_taxonomies"] = menu_categories_value

          component.update_column(:settings, raw_settings) # rubocop:disable Rails/SkipsModelValidations

          updated_count += 1

          puts "Updated component ID: #{component.id}"
          puts "  Changed menu_categories: #{menu_categories_value} -> menu_taxonomies: #{menu_categories_value}"
        end
      end

      puts "Migration completed. Updated #{updated_count} components."
    end
  end
end
