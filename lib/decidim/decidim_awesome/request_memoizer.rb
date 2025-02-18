# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module RequestMemoizer
      # memoize a piece of code in the global request instead of the helper instance (helpers are initialized for each view)
      def memoize(key)
        if defined?(request) && request.env["decidim.current_organization"]&.id
          request.env["decidim_awesome.#{key}"] ||= block_given? ? yield : nil
        elsif block_given?
          yield
        end
      end
    end
  end
end
