# frozen_string_literal: true

Decidim::AmendmentsHelper.module_eval do
  # override with custom fields if scope applies
  def amendments_form_field_for(attribute, form, original_resource)
    custom_fields = awesome_custom_fields(attribute, form)
    return decidim_amendments_form_field_for(attribute, form, original_resource) if custom_fields.blank?

    render_amendment_custom_fields_override(custom_fields, attribute, form, original_resource)
  end

  private

  def render_amendment_custom_fields_override(fields, attribute, form, original_resource)
    custom_fields = Decidim::DecidimAwesome::CustomFields.new(fields)
    custom_fields.translate!
    body = amendments_form_fields_value(original_resource, attribute)
    custom_fields.apply_xml(body) if body.present?
    # TODO: find a way to add errors as form is not the parent form
    # form.object.errors.add(attribute, custom_fields.errors) if custom_fields.errors
    render partial: "decidim/decidim_awesome/custom_fields/form_render", locals: { spec: custom_fields.to_json, form: form, name: attribute }
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
    awesome_config.collect_sub_configs("proposal_custom_field")
  end

  # original method
  def decidim_amendments_form_field_for(attribute, form, original_resource)
    options = {
      class: "js-hashtags",
      label: amendments_form_fields_label(attribute),
      value: amendments_form_fields_value(original_resource, attribute)
    }

    case attribute
    when :title
      form.text_field(:title, options)
    when :body
      text_editor_for(form, :body, options.merge(hashtaggable: true))
    end
  end
end
