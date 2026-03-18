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
      attribute :background_color, String
      attribute :background_image_placement, String, default: "cover_center"

      PLACEMENT_OPTIONS = %w(cover_center cover_top cover_bottom contain_center repeat).freeze

      def self.from_settings(data)
        return [new] if data.blank?

        items = data.is_a?(Hash) ? data.values : Array(data)
        items.first(Decidim::DecidimAwesome.max_rich_text_columns).map { |attrs| new(attrs) }
      end
    end
  end
end
