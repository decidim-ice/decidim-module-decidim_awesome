# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      class UpdateFollowUpQuestionnaireStatus < Decidim::Commands::UpdateResource
        fetch_form_attributes :name, :color
      end
    end
  end
end
