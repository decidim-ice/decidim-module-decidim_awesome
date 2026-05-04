# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module ModerationRules
      class WordFilter
        def initialize(options)
          @options = options
        end

        # Checks if the object contains any of the specified words in its body.
        # returns true if any of the words are found, false otherwise.
        def check(object)
          return false unless object.respond_to?(:body)

          @options.any? do |word|
            object.body.values.any? { |v| v.include?(word) }
          end
        end
      end
    end
  end
end
