# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module ProposalFormOverride
        extend ActiveSupport::Concern

        included do
          alias_method :decidim_original_map_model, :map_model
          attribute :private_body, String

          def map_model(model)
            decidim_original_map_model(model)
            self.private_body = model.private_body
          end
        end
      end
    end
  end
end
