# frozen_string_literal: true

require_dependency "decidim/components/namer"

Decidim.register_component(:decidim_awesome) do |component|
  component.engine = Decidim::DecidimAwesome::Engine
  component.admin_engine = Decidim::DecidimAwesome::AdminEngine
  # component.icon = "decidim/decidim_awesome/icon.svg"
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

  # component.register_resource(:assignee) do |resource|
  #   # Register a optional resource that can be references from other resources.
  #   resource.model_class_name = "Decidim::DecidimAwesome::Assignee"
  #   # TODO!:
  #   # resource.template = "decidim/decidim_awesome/decidim_awesome/linked_tasks"
  #   resource.card = "decidim/decidim_awesome/assignee"
  #   # resource.actions = %w(join)
  #   # resource.searchable = true
  # end

  # component.register_stat :some_stat do |context, start_at, end_at|
  #   # Register some stat number to the application
  # end

  # component.seeds do |participatory_space|
  #   # Add some seeds for this component
  # end
end
