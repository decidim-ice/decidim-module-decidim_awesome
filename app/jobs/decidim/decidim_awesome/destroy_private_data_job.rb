# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class DestroyPrivateDataJob < ApplicationJob
      queue_as :default

      # Destroys private data associated with the resource
      def perform(resource)
        extra_fields = Decidim::DecidimAwesome::ProposalExtraField.where(
          proposal: Decidim::Proposals::Proposal.where(component: resource)
        ).where(private_body_updated_at: ...DecidimAwesome.private_data_expiration_time.ago)

        extra_fields.find_each do |extra_field|
          extra_field.update(private_body: nil)
        end

        Lock.new(resource.organization).release!(resource)
      end
    end
  end
end
