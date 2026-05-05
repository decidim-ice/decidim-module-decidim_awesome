# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module AutoModeration
      module Rules
        class WordFilter
          def initialize(options)
            @options = options
          end

          # Checks if the object contains any of the specified words in its body.
          # returns true if any of the words are found, false otherwise.
          def check(object)
            return false unless object.respond_to?(:body)

            @options.any? do |word|
              object.body.values.any? { |v| v.mb_chars.downcase.to_s
  .include?(word.mb_chars.downcase.to_s) }
            end
          end
        end
      end
    end
  end
end
