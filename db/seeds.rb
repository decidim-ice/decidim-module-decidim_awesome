# frozen_string_literal: true

if !Rails.env.production? || ENV.fetch("SEED", nil)
  print "Creating seeds for decidim_awesome...\n" unless Rails.env.test?

  organization = Decidim::Organization.first

  # Set the htmleditor on to facilitate development
  admin_user = Decidim::User.find_by(
    organization:,
    email: "admin@example.org"
  )

  Decidim.traceability.update!(
    organization,
    admin_user,
    rich_text_editor_in_public_views: true
  )

  # Enable images in general
  setting = Decidim::DecidimAwesome::AwesomeConfig.find_or_initialize_by(var: :allow_images_in_full_editor, organization:)
  setting.value = true
  setting.save!
  setting = Decidim::DecidimAwesome::AwesomeConfig.find_or_initialize_by(var: :allow_images_in_small_editor, organization:)
  setting.value = true
  setting.save!
end
