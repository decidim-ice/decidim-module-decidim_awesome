# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class ModerationProcessorJob < Decidim::ApplicationJob
      queue_as :default

      def perform(object)
        Decidim::DecidimAwesome::Processors::ModerationProcessor.process(object)
      end
    end
  end
end
