# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class CreateFollowUpQuestionnaire < Decidim::Commands::CreateResource
        include Decidim::TranslatableAttributes

        protected

        def resource_class = Decidim::DecidimAwesome::FollowUpQuestionnaire

        def attributes
          form.to_params.merge(organization: form.current_organization, component: form.component)
        end

        def extra_params
          { resource: { follow_up_questionnaire_name: translated_attribute(form.name) } }
        end

        def run_after_hooks
          Decidim::DecidimAwesome.create_default_statuses!(resource)
        end
      end
    end
  end
end
