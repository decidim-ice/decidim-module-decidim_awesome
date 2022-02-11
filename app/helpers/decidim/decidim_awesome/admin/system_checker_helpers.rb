# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module SystemCheckerHelpers
        def decidim_version
          Decidim.version
        end

        def decidim_version_valid?
          @decidim_version_valid ||= Gem::Dependency.new("", DecidimAwesome::COMPAT_DECIDIM_VERSION).match?("", decidim_version, true)
        end

        def overrides
          SystemChecker.to_h
        end

        def valid?(spec, file)
          SystemChecker.valid?(spec, file)
        end

        def images_migrated?
          pending_image_migrations.zero?
        end

        def pending_image_migrations
          @pending_image_migrations ||= begin
            images = Decidim::DecidimAwesome::EditorImage.where(organization: current_organization)
            images.count - images.joins(:file_attachment).count
          end
        end
      end
    end
  end
end
