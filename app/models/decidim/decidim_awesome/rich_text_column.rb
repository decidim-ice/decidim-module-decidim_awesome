# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    # Plain data object representing a single column in the Awesome RichText
    # content block. Not backed by a database table — serialized as part of
    # the content block's JSONB settings.
    class RichTextColumn
      include Decidim::AttributeObject::Model
      include TranslatableAttributes

      translatable_attribute :body, Decidim::Attributes::RichText
      attribute :restrict_videos, Boolean, default: false
      attribute :restrict_links, Boolean, default: false

      def self.from_settings(array)
        return [new] if array.blank?

        Array(array).first(Decidim::DecidimAwesome.max_rich_text_columns).map { |hash| new(hash) }
      end
    end
  end
end
