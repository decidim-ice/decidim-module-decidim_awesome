# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    module AmendmentsHelperOverride
      extend ActiveSupport::Concern

      included do
        # original method
        alias_method :decidim_amendments_form_field_for, :amendments_form_field_for

        # override with custom fields if scope applies
        def amendments_form_field_for(attribute, form, original_resource)
          custom_fields, custom_private_fields = awesome_custom_fields(attribute, form)
          content = if custom_fields.blank?
                      decidim_amendments_form_field_for(attribute, form, original_resource)
                    else
                      render_amendment_custom_fields_override(custom_fields, attribute, form, original_resource)
                    end
          if custom_private_fields.present?
            content = content_tag("div", content)
            content += content_tag("div", render_amendment_custom_fields_override(custom_private_fields, :private_body, form, original_resource))
          end
          content
        end

        private

        def render_amendment_custom_fields_override(custom_fields, attribute, form, original_resource)
          # ensure decidim_editor is available as it is only required if the original FormBuilder is called
          stylesheet_pack_tag "decidim_editor"
          javascript_pack_tag "decidim_editor", defer: false

          custom_fields.translate!
          body = amendments_form_fields_value(original_resource, attribute)
          custom_fields.apply_xml(body) if body.present?
          # TODO: find a way to add errors as form is not the parent form
          # form.object.errors.add(attribute, custom_fields.errors) if custom_fields.errors

          editor_image = Decidim::EditorImage.new
          editor_options = form.send(:editor_options, editor_image, { context: "participant", lines: 10 })
          editor_upload = form.send(:editor_upload, editor_image, editor_options[:upload])
          render partial: "decidim/decidim_awesome/custom_fields/form_render",
                 locals: { spec: custom_fields.to_json, editor_options: editor_options, editor_upload: editor_upload, form: form, name: attribute }
        end

        # Amendments don't use a URL specifying participatory space and component
        # context for awesome config constraints must be obtained from the resource
        def awesome_custom_fields(attribute, _form)
          return unless attribute == :body

          component = amendable.try(:component)
          return unless component
          return if component.settings.participatory_texts_enabled?

          awesome_config = Decidim::DecidimAwesome::Config.new(component.organization)
          awesome_config.context_from_component(component)

          pub = awesome_config.collect_sub_configs_values("proposal_custom_field")
          priv = awesome_config.collect_sub_configs_values("proposal_private_custom_field")
          [pub.presence && Decidim::DecidimAwesome::CustomFields.new(pub), priv.presence && Decidim::DecidimAwesome::CustomFields.new(priv)]
        end
      end
    end
  end
end
