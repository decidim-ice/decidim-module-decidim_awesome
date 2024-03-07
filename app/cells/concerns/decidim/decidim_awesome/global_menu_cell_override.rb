# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module GlobalMenuCellOverride
      extend ActiveSupport::Concern

      included do
        def cache_hash
          [
            "decidim/content_blocks/global_menu",
            current_organization.cache_key_with_version,
            I18n.locale,
            awesome_config[:home_content_block_menu].to_s
          ].join(Decidim.cache_key_separator)
        end
      end
    end
  end
end
