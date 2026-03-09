# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContentBlocks
      class LandingMenuFormCell < Decidim::ViewModel
        alias form model

        def content_block
          options[:content_block]
        end

        def i18n_scope
          "decidim.decidim_awesome.content_blocks.landing_menu"
        end

        def alignment_options
          %w(left center right).map do |value|
            [t("alignment_#{value}", scope: i18n_scope), value]
          end
        end
      end
    end
  end
end
