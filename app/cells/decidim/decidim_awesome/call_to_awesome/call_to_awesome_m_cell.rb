# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module CallToAwesome
      # This cell renders the Medium (:m) CallToAwesome card
      # for an given instance of a Component
      class CallToAwesomeMCell < Decidim::CardMCell
        include CallToAwesomeCellsHelper

        def title
          decidim_html_escape(translated_attribute(model.name))
        end

        def description; end

        def type
          model.manifest_name
        end

        private

        def has_badge?
          false
        end

        def card_classes
          classes = [base_card_class]
          classes = classes.concat(["card--stack"]) if has_children?
          return classes.join(" ") unless has_state?

          classes.concat(state_classes).join(" ")
        end

        def has_children?
          items.count > 1
        end

        def statuses
          [:items_count]
        end

        def label
          "hola"
        end

        def resource_icon
          icon model.manifest_name, class: "icon--big"
        end

        def resource_path
          raise NotImplementedError
        end

        def items
          raise NotImplementedError
        end
      end
    end
  end
end
