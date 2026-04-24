# frozen_string_literal: true

module Decidim
    module DecidimAwesome
        class ModerationProcessorJob < Decidim::ApplicationJob
            queue_as :default

            def perform(proposal)
                Decidim::DecidimAwesome::Processors::ModerationProcessor.new(proposal).process
            end
        end
    end
end