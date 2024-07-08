import "formBuilder/dist/form-builder.min.js";
import "src/decidim/decidim_awesome/forms/rich_text_plugin"
// formBuilder uses jquery-ui-sortable which is a very dirty npm package with no neat source code available, and causes problems with the webpacker configuration of Decidim.
// For the moment, we'll remove the sortable functionality with a dummy jQuery plugin until we find another sortable plugin (or keep it disabled for good)
jQuery.fn.sortable = () => {}

window.CustomFieldsBuilders = window.CustomFieldsBuilders || [];

/**
 * Build the configuration for a Builder dom element
 * @param {DOMElement} el JQuery Element to instanciate the builder
 * @param {String} key The proposal box name
 * @param {String} name the name of the input used to save the configuration. Default: `proposal_custom_fields`
 * @returns {Record<FormBuilderOptions>} Options for the FormBuilder
 */
const builderConfig = (el, key, name = "proposal_custom_fields") => {
  const formEl = $(`input[name="config[${name}][${key}]"]`)
  // DOCS: https://formbuilder.online/docs
  return {
    formEl: formEl,
    el: el,
    key: key,
    config: {
      i18n: {
        locale: "en-US",
        location: "https://cdn.jsdelivr.net/npm/formbuilder-languages@1.1.0/"
      },
      formData: formEl.val(),
      disableFields: ["button", "file"],
      disabledActionButtons: ["save", "data", "clear"],
      disabledAttrs: [
        "access",
        "inline",
        "className"
      ],
      controlOrder: [
        "text",
        "textarea",
        "number",
        "date",
        "checkbox-group",
        "radio-group",
        "select",
        "autocomplete",
        "header",
        "paragraph"
      ],
      disabledSubtypes: {
        // default color as it generate hashtags in decidim (TODO: fix hashtag generator with this)
        text: ["color"],
        // disable default wysiwyg editors as they present problems
        textarea: ["tinymce", "quill"]
      }
    },
    instance: null
  };
}
$(() => {
  $(".awesome-edit-config .proposal_custom_fields_container").each((_idx, container) => {
    const key = $(container).data("key");
    const el = $(container).find(".proposal_custom_fields_editor")
    const privateEl = $(container).find(".proposal_custom_fields_editor--private")
    window.CustomFieldsBuilders.push(builderConfig(el, key));
    window.CustomFieldsBuilders.push(builderConfig(privateEl, key, "proposal_private_custom_fields"));
  });

  $(document).on("formBuilder.create", (_event, idx, list) => {
    if (!list[idx]) {
      return;
    }

    $(list[idx].el).formBuilder(list[idx].config).promise.then(function(res) {
      list[idx].instance = res;
      // Attach to DOM
      list[idx].el.FormBuilder = res;
      // remove spinner
      $(list[idx].el).find(".loading-spinner").remove();
      // for external use
      $(document).trigger("formBuilder.created", [list[idx]]);
      if (idx < list.length) {
        $(document).trigger("formBuilder.create", [idx + 1, list]);
      }
    });
  });

  if (window.CustomFieldsBuilders.length) {
    $(document).trigger("formBuilder.create", [0, window.CustomFieldsBuilders]);
  }

  $("form.awesome-edit-config").on("submit", () => {
    window.CustomFieldsBuilders.forEach(({formEl, ...builder}) => {
      formEl.val(builder.instance.actions.getData("json"));
    });
  });
});
