# frozen_string_literal: true

namespace :decidim_awesome do
  namespace :active_storage_migrations do
    desc "Migrates editor images from Carrierwave to ActiveStorage"
    task migrate_from_carrierwave: :environment do
      stdout = Logger.new($stdout)
      stdout.level = Logger::INFO
      Rails.logger.extend(ActiveSupport::Logger.broadcast(stdout))
      Decidim::Organization.find_each do |organization|
        puts "Migrating Organization #{organization.id} (#{organization.host})..."
        routes_mappings = []
        Decidim::DecidimAwesome::MigrateLegacyImagesJob.perform_now(organization.id, routes_mappings)

        path = Rails.root.join("tmp/decidim_awesome_editor_images_mappings.csv")
        dirname = File.dirname(path)
        FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
        File.binwrite(path, Decidim::Exporters::CSV.new(routes_mappings).export.read)
      end
    end

    desc "Checks editor images migrated from Carrierwave to ActiveStorage"
    task check_migration_from_carrierwave: :environment do
      logger = ActiveSupport::TaggedLogging.new(Logger.new($stdout))

      Decidim::CarrierWaveMigratorService.check_migration(
        klass: Decidim::DecidimAwesome::EditorImage,
        cw_attribute: "image",
        cw_uploader: Decidim::Cw::DecidimAwesome::ImageUploader,
        as_attribute: "file",
        logger: logger
      )
    end
  end
end
