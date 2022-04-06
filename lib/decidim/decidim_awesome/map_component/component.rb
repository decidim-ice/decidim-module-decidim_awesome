# frozen_string_literal: true

require "decidim/components/namer"

Decidim::DecidimAwesome.register_component(:awesome_map) do |component|
  component.engine = Decidim::DecidimAwesome::MapComponent::Engine
  component.admin_engine = Decidim::DecidimAwesome::MapComponent::AdminEngine
  component.icon = "media/images/decidim_meetings.svg" # TODO: create a Icon
  component.permissions_class_name = "Decidim::DecidimAwesome::Permissions"

  # These actions permissions can be configured in the admin panel
  # component.actions = %w()

  component.settings(:global) do |settings|
    # Add your global settings
    # Available types: :integer, :boolean
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :map_height, type: :integer, default: 700
    settings.attribute :map_center, type: :string, default: ""
    settings.attribute :map_zoom, type: :integer, default: 8
    settings.attribute :truncate, type: :integer, default: 255
    settings.attribute :collapse, type: :boolean, default: false
    settings.attribute :menu_amendments, type: :boolean, default: true
    settings.attribute :menu_meetings, type: :boolean, default: true
    settings.attribute :menu_categories, type: :boolean, default: true
    settings.attribute :menu_hashtags, type: :boolean, default: true
    settings.attribute :menu_merge_components, type: :boolean, default: false
  end

  component.settings(:step) do |settings|
    # Add your settings per step
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :show_not_answered, type: :boolean, default: true
    settings.attribute :show_evaluating, type: :boolean, default: true
    settings.attribute :show_accepted, type: :boolean, default: true
    settings.attribute :show_rejected, type: :boolean, default: false
    settings.attribute :show_withdrawn, type: :boolean, default: false
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
        announcement: { en: Faker::Lorem.paragraphs(number: 2).join("\n") }
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

    # Tweak proposals in Assemblies to geolocate them
    next unless participatory_space.manifest.name == :assemblies

    participatory_space.components.each do |comp|
      next unless comp.manifest.name == :proposals

      comp.attributes["settings"]["global"]["geocoding_enabled"] = true
      comp.save!

      Decidim::Proposals::Proposal.where(component: comp).each do |proposal|
        proposal.address = "#{Faker::Address.street_address} #{Faker::Address.zip} #{Faker::Address.city}"
        proposal.latitude = Faker::Address.latitude
        proposal.longitude = Faker::Address.longitude
        proposal.save!
      end
    end
  end
end
