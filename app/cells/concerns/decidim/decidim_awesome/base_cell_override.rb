# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module BaseCellOverride
      def block_id
        super.presence || "awesome-content-block-#{model.manifest_name}-#{model.id}"
      end
    end
  end
end
