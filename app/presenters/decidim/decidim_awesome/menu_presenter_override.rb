# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module MenuPresenterOverride
      extend ActiveSupport::Concern

      included do
        def evaluated_menu
          @evaluated_menu ||= if awesome_override?
                                Decidim::DecidimAwesome::MenuHacker.new(@name, @view)
                              else
                                begin
                                  menu = Decidim::Menu.new(@name)
                                  menu.build_for(@view)
                                  menu
                                end
                              end
        end

        private

        def awesome_override?
          return false unless Decidim::DecidimAwesome.config.has_key?(@name)

          Decidim::DecidimAwesome.config.send(@name) != :disabled
        end
      end
    end
  end
end
