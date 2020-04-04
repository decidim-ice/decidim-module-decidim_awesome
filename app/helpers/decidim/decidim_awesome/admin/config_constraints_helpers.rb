# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      module ConfigConstraintsHelpers
        def participatory_space_manifests
          Decidim.participatory_space_manifests.pluck(:name).map do |name|
            [name.to_sym, I18n.t("decidim.admin.menu.#{name}")]
          end.to_h
        end

        def translate_constraint_value(key, value)
          case key.to_sym
          when :participatory_space_manifest
            participatory_space_manifests[value.to_sym] || value
          else
            value
          end
        end
      end
    end
  end
end
