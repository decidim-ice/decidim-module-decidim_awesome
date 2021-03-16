# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module OverviewComponent
      # This cell renders the Medium (:m) overview card
      # for an given instance of a Component
      class OverviewMCell < Decidim::CardMCell
        def title
          translated_attribute model.name
        end

        def description; end

        def type
          model.manifest_name
        end

        private

        def has_children?
          items.count > 1
        end

        def resource_icon
          icon model.manifest_name, class: "icon--big"
        end

        def resource_path
          Decidim::Assemblies::Engine.routes.url_helpers.assembly_path(model)
        end

        def statuses
          collection = [:creation_date, :items_count]
          collection << :follow if model.is_a?(Decidim::Followable) && model != try(:current_user)
          collection
        end

        def items; end

        def items_count_title
          t([i18n_scope, type, "items_count"].join("."), count: items.count)
        end

        def items_count_status
          link_to resource_path, "aria-label" => items_count_title, title: items_count_title do
            render_items_count
          end
        end

        def render_items_count
          with_tooltip items_count_title do
            items_count_title
          end
        end

        def i18n_scope
          "decidim.components.awesome_overview.components"
        end
      end
    end
  end
end
