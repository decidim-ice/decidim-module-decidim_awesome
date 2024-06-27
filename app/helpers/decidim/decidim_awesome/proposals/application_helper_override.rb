# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module Proposals
      module ApplicationHelperOverride
        extend ActiveSupport::Concern

        included do
          alias_method :decidim_text_editor_for_proposal_body, :text_editor_for_proposal_body
          alias_method :decidim_render_proposal_body, :render_proposal_body

          # If the content is safe, HTML tags are sanitized, otherwise, they are stripped.
          def render_proposal_body(proposal)
            if awesome_proposal_custom_fields.present? || awesome_config[:allow_images_in_full_editor] || awesome_config[:allow_images_in_small_editor]
              content = present(proposal).body(links: true, strip_tags: false)
              sanitized = decidim_sanitize_editor_admin(content, {})
              Decidim::ContentProcessor.render_without_format(sanitized).html_safe
            else
              decidim_render_proposal_body(proposal)
            end
          end

          # replace normal method to draw the editor
          def text_editor_for_proposal_body(form)
            custom_fields = awesome_proposal_custom_fields

            return decidim_text_editor_for_proposal_body(form) if custom_fields.blank?

            custom_field_form = render_proposal_custom_fields_override(custom_fields, form, :body)
            custom_field_form + render_proposal_custom_fields_override(awesome_private_proposal_custom_fields, form, :private_body)
          end

          # replace admin method to draw the editor (multi lang)
          def admin_editor_for_proposal_body(form)
            custom_fields = awesome_proposal_custom_fields

            return form.translated(:editor, :body, hashtaggable: true) if custom_fields.blank?

            locales = form.send(:locales)
            return render_proposal_custom_fields_override(custom_fields, form, "body_#{locales.first}", locales.first) if locales.length == 1

            tabs_id = form.send(:sanitize_tabs_selector, form.options[:tabs_id] || "#{form.object_name}-body-tabs")

            label_tabs = form.content_tag(:div, class: "label--tabs") do
              field_label = form.send(:label_i18n, "body", form.label_for("proposal_custom_fields"), required: form.options[:required])

              language_selector = "".html_safe
              language_selector = form.create_language_selector(locales, tabs_id, "body") if form.options[:label] != false

              safe_join [field_label, language_selector]
            end

            tabs_content = form.content_tag(:div, class: "tabs-content", data: { tabs_content: tabs_id }) do
              locales.each_with_index.inject("".html_safe) do |string, (locale, index)|
                tab_content_id = "#{tabs_id}-body-panel-#{index}"
                string + content_tag(:div, class: form.send(:tab_element_class_for, "panel", index), id: tab_content_id, "aria-hidden": index.zero? ? "false" : "true") do
                  render_proposal_custom_fields_override(custom_fields, form, "body_#{locale}", locale)
                end
              end
            end

            safe_join [label_tabs, tabs_content]
          end

          def render_proposal_custom_fields_override(fields, form, name, locale = nil)
            # ensure decidim_editor is available as it is only required if the original FormBuilder is called
            append_stylesheet_pack_tag "decidim_editor"
            append_javascript_pack_tag "decidim_editor", defer: false

            custom_fields = Decidim::DecidimAwesome::CustomFields.new(fields)
            custom_fields.translate!
            proposal_body = if name == :private_body
                              form_presenter.private_body(extras: false, all_locales: locale.present?)
                            else
                              form_presenter.body(extras: false, all_locales: locale.present?)
                            end
            body = if locale.present?
                     proposal_body.with_indifferent_access[locale]
                   else
                     proposal_body
                   end
            custom_fields.apply_xml(body) if body.present?
            form.object.errors.add(name, custom_fields.errors) if custom_fields.errors
            editor_image = Decidim::EditorImage.new
            editor_options = form.send(:editor_options, editor_image, { context: "participant", lines: 10 })
            editor_upload = form.send(:editor_upload, editor_image, editor_options[:upload])
            render partial: "decidim/decidim_awesome/custom_fields/form_render", locals: { spec: custom_fields.to_json, editor_options:, editor_upload:, form:, name: }
          end
        end
      end
    end
  end
end
