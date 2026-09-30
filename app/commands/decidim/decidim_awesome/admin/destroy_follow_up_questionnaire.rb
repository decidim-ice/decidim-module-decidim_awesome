# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class DestroyFollowUpQuestionnaire < Decidim::Commands::DestroyResource
        include Decidim::TranslatableAttributes

        protected

        def invalid? = !resource.removable?

        def extra_params
          { resource: { follow_up_questionnaire_name: translated_attribute(resource.name) } }
        end
      end
    end
  end
end
