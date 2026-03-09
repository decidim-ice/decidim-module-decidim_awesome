# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ContentBlocks
      class LandingMenuCell < Decidim::ContentBlocks::BaseCell
        def show
          render
        end

        def block_id
          "awesome-landing-menu-#{model.id}"
        end

        def i18n_scope
          "decidim.decidim_awesome.content_blocks.landing_menu"
        end
      end
    end
  end
end
