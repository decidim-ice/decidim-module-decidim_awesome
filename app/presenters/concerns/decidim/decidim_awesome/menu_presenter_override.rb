# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module MenuPresenterOverride
      extend ActiveSupport::Concern

      included do
        def evaluated_menu
          @evaluated_menu ||= if DecidimAwesome.enabled?(@name)
                                Decidim::DecidimAwesome::MenuHacker.new(@name, @view)
                              else
                                begin
                                  menu = Decidim::Menu.new(@name)
                                  menu.build_for(@view)
                                  menu
                                end
                              end
        end
      end
    end
  end
end
