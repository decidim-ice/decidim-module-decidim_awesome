# frozen_string_literal: true

Decidim::Proposals::ApplicationHelper.module_eval do
  # replace normal method to draw the editor
  def text_editor_for_proposal_body(form)
    custom_fields = awesome_proposal_custom_fields

    return normal_text_editor_for_proposal_body(form) if custom_fields.blank?

    apply_custom_fields_override(custom_fields, form)
  end

  def apply_custom_fields_override(fields, form)
    custom_fields = Decidim::DecidimAwesome::CustomFields.new(fields)
    custom_fields.apply_xml(form_presenter.body(extras: false).strip)
    console
    render partial: "decidim/decidim_awesome/custom_fields/form_render", locals: { spec: custom_fields.to_json, form: form }
  end

  # original function from ApplicationHelper
  def normal_text_editor_for_proposal_body(form)
    options = {
      class: "js-hashtags",
      hashtaggable: true,
      value: form_presenter.body(extras: false).strip
    }

    text_editor_for(form, :body, options)
  end
end
