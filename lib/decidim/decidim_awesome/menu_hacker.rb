# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class MenuHacker
      include Decidim::TranslatableAttributes
      def initialize(name, organization, view)
        @name = name
        @organization = organization
        @view = view
      end

      # returns a combined array of the Decidim defined menu and the hacked stored as config vars
      def items
        return @items if @items

        menu = Decidim::Menu.new(name)
        menu.build_for(view)
        addons = menu_overrides
        merged = menu.instance_variable_get(:@items).map do |item|
          override = menu_overrides.find { |i| i.url == item.url }
          if override
            addons.reject! { |i| i.url == item.url }
            override.send("overrided?=", true)
            override
          else
            item
          end
        end
        (merged + addons).sort_by(&:position)
      end

      private

      attr_reader :name, :view, :organization

      def menu_overrides
        return @menu_overrides if @menu_overrides

        menu = AwesomeConfig.find_by(var: name, organization: organization).value || []
        @menu_overrides = menu.map do |item|
          OpenStruct.new(
            label: translated_attribute(item["label"]),
            url: item["url"],
            position: item["position"] || 1,
            overrided?: false
          )
        end
      end
    end
  end
end
