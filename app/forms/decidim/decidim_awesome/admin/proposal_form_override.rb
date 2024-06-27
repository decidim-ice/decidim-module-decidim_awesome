# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module ProposalFormOverride
        extend ActiveSupport::Concern

        included do
          include Decidim::TranslatableAttributes
          alias_method :decidim_original_map_model, :map_model
          translatable_attribute :private_body, String

          def map_model(model)
            decidim_original_map_model(model)
            self.private_body = translated_attribute(model.private_body)
          end
        end
      end
    end
  end
end
