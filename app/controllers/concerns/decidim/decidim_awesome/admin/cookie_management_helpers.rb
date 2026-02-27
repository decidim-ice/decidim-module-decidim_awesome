# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module CookieManagementHelpers
        extend ActiveSupport::Concern

        included do
          include NeedsAwesomeConfig
          include ConfigConstraintsHelpers
          include HasCookieCategories
          include CookieBreadcrumbHelper

          helper ConfigConstraintsHelpers
        end

        private

        def cookie_management_setting
          @cookie_management_setting ||= AwesomeConfig.find_or_initialize_by(
            var: :cookie_management,
            organization: current_organization
          )
        end

        def categories_data
          @categories_data ||= begin
            data = cookie_management_setting.value
            data = {} unless data.is_a?(Hash)
            data["categories"] = [] unless data["categories"].is_a?(Array)
            data
          end
        end

        def current_categories
          categories_data["categories"]
        end

        def save_categories!(categories)
          cookie_management_setting.value = { "categories" => categories }
          cookie_management_setting.save!
        end

        def visibility_options
          MenuForm::VISIBILITY_STATES.index_by do |key|
            I18n.t(".menu_hacks.form.visibility.#{key}", scope: "decidim.decidim_awesome.admin")
          end
        end
      end
    end
  end
end
