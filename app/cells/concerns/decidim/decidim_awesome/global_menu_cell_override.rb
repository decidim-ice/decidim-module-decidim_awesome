# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module GlobalMenuCellOverride
      extend ActiveSupport::Concern

      included do
        private

        alias_method :decidim_original_cache_hash, :cache_hash

        def cache_hash
          return nil if decidim_original_cache_hash.blank?

          @decidim_awesome_cache_hash ||= begin
            filtered_extra_cache_keys = extra_cache_keys.reject(&:blank?)
            [decidim_original_cache_hash, *filtered_extra_cache_keys].join(Decidim.cache_key_separator)
          end
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
