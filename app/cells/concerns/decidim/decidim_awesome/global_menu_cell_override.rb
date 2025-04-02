# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module GlobalMenuCellOverride
      extend ActiveSupport::Concern

      included do
        private

        def cache_hash
          @decidim_awesome_cache_hash ||= [
            "decidim/content_blocks/global_menu",
            current_organization.cache_key_with_version,
            I18n.locale,
            *extra_cache_keys
          ].join(Decidim.cache_key_separator)
        end

        def extra_cache_keys
          [].tap do |array|
            array << awesome_config[:home_content_block_menu].to_s
            if defined?(current_user) && current_user
              array << current_user.id
              array << Decidim::Authorization.find_by(user: current_user)&.cache_key_with_version
            end
          end
        end
      end
    end
  end
end
