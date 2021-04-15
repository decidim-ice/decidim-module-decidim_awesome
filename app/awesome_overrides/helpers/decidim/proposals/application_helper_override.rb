# frozen_string_literal: true

Decidim::Proposals::ApplicationHelper.module_eval do
  # replace safe content to consider all custom fields save (then embeded html will be rendered)
  def safe_content?
    awesome_proposal_custom_fields.present? || decidim_safe_content?
  end

  # replace normal method to draw the editor
  def text_editor_for_proposal_body(form)
    custom_fields = awesome_proposal_custom_fields

    return decidim_text_editor_for_proposal_body(form) if custom_fields.blank?

    render_proposal_custom_fields_override(custom_fields, form, :body, current_locale)
  end

  # replace admin method to draw the editor (multi lang)
  def admin_editor_for_proposal_body(form)
    custom_fields = awesome_proposal_custom_fields

    return form.translated(:editor, :body, hashtaggable: true) if custom_fields.blank?

    locales = form.send(:locales)

    return render_proposal_custom_fields_override(custom_fields, form, "body_#{locales.first}", locales.first) if locales.length == 1

    tabs_id = form.send(:sanitize_tabs_selector, form.options[:tabs_id] || "#{form.object_name}-body-tabs")

    label_tabs = form.content_tag(:div, class: "label--tabs") do
      field_label = form.send(:label_i18n, "body", form.label_for("proposal_custom_fields"))

      language_selector = "".html_safe
      language_selector = form.create_language_selector(locales, tabs_id, "body") if form.options[:label] != false

      safe_join [field_label, language_selector]
    end

    tabs_content = form.content_tag(:div, class: "tabs-content", data: { tabs_content: tabs_id }) do
      locales.each_with_index.inject("".html_safe) do |string, (locale, index)|
        tab_content_id = "#{tabs_id}-body-panel-#{index}"
        string + content_tag(:div, class: form.send(:tab_element_class_for, "panel", index), id: tab_content_id) do
          render_proposal_custom_fields_override(custom_fields, form, "body_#{locale}", locale)
        end
      end
    end

    safe_join [label_tabs, tabs_content]
  end

  def render_proposal_custom_fields_override(fields, form, name, locale)
    custom_fields = Decidim::DecidimAwesome::CustomFields.new(fields)
    body = if form_presenter.proposal.body.is_a?(Hash)
             form_presenter.body(extras: false, all_locales: true)[locale]
           else
             form_presenter.body(extras: false)
           end
    custom_fields.apply_xml(body) if body.present?
    form.object.errors.add(name, custom_fields.errors) if custom_fields.errors
    render partial: "decidim/decidim_awesome/custom_fields/form_render", locals: { spec: custom_fields.to_json, form: form, name: name }
  end

  private

  # original functions from ApplicationHelper
  def decidim_text_editor_for_proposal_body(form)
    options = {
      class: "js-hashtags",
      hashtaggable: true,
      value: form_presenter.body(extras: false).strip
    }

    text_editor_for(form, :body, options)
  end

  # If the proposal is official or the rich text editor is enabled on the
  # frontend, the proposal body is considered as safe content; that's unless
  # the proposal comes from a collaborative_draft or a participatory_text.
  def decidim_safe_content?
    rich_text_editor_in_public_views? && not_from_collaborative_draft(@proposal) ||
      (@proposal.official? || @proposal.official_meeting?) && not_from_participatory_text(@proposal)
  end
end
