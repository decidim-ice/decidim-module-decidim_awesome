# frozen_string_literal: true

require_dependency "decidim/components/namer"

Decidim.register_component(:awesome_map) do |component|
  component.engine = Decidim::DecidimAwesome::MapComponent::Engine
  # component.admin_engine = Decidim::DecidimAwesome::AdminMapEngine
  component.icon = "decidim/meetings/icon.svg" # TODO: create a Icon
  component.permissions_class_name = "Decidim::DecidimAwesome::Permissions"

  # These actions permissions can be configured in the admin panel
  # component.actions = %w()

  component.settings(:global) do |settings|
    # Add your global settings
    # Available types: :integer, :boolean
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.settings(:step) do |settings|
    # Add your settings per step
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  # component.register_stat :some_stat do |context, start_at, end_at|
  #   # Register some stat number to the application
  # end

  component.seeds do |participatory_space|
    # Create a Map and a few geolocated proposals
    admin_user = Decidim::User.find_by(
      organization: participatory_space.organization,
      email: "admin@example.org"
    )

    params = {
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :awesome_map).i18n_name,
      manifest_name: :awesome_map,
      published_at: Time.current,
      participatory_space: participatory_space,
      settings: {
        announcement: { en: Faker::Lorem.paragraphs(2).join("\n") }
      }
    }

    component = Decidim.traceability.perform_action!(
      "publish",
      Decidim::Component,
      admin_user,
      visibility: "all"
    ) do
      Decidim::Component.create!(params)
    end
  end
end
