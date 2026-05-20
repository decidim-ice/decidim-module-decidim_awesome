# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Admin
      # Extends Decidim::Admin::SettingsHelper to render :array attributes with choices
      # as a multi-select picker (TomSelect). Stock Decidim has no renderer for :array,
      # so without this override the field would crash on render.
      module SettingsHelperOverride
        extend ActiveSupport::Concern

        included do
          alias_method :awesome_original_form_method_for_attribute, :form_method_for_attribute
          alias_method :awesome_original_render_field_form_method, :render_field_form_method

          def form_method_for_attribute(attribute, options)
            return :awesome_multiselect if attribute.type.to_sym == :array && attribute.choices.present?

            awesome_original_form_method_for_attribute(attribute, options)
          end

          # rubocop:disable Metrics/ParameterLists
          def render_field_form_method(form_method, form, attribute, name, i18n_scope, options)
            return awesome_render_multiselect(form, attribute, name, options) if form_method == :awesome_multiselect

            awesome_original_render_field_form_method(form_method, form, attribute, name, i18n_scope, options)
          end
          # rubocop:enable Metrics/ParameterLists

          private

          def awesome_render_multiselect(form, attribute, name, options)
            choices = attribute.build_choices(component: @component) || []

            html_options = { multiple: true }
            html_options[:data] = { controller: "awesome-votes-by-status" } if name.to_sym == :awesome_votes_enabled_states

            select_html = form.select(
              name,
              choices,
              { include_blank: false, label: options[:label] },
              html_options
            )
            # Help only matters before save (when the list shows just "Not answered"); hide it for persisted components.
            help_text = options[:help_text]
            help_text = nil if name.to_sym == :awesome_votes_enabled_states && @component&.persisted?
            select_html << content_tag(:p, help_text, class: "help-text") if help_text
            select_html
          end
        end
      end
    end
  end
end
