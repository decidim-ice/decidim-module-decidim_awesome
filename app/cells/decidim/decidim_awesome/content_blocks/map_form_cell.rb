# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContentBlocks
      class MapFormCell < Decidim::ViewModel
        alias form model

        def content_block
          options[:content_block]
        end

        def i18n_scope
          "decidim.decidim_awesome.content_blocks.map"
        end
      end
    end
  end
end
