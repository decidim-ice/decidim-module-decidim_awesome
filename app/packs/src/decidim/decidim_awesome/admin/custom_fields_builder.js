require("formBuilder/dist/form-builder.min.js")
import "src/decidim/decidim_awesome/forms/rich_text_plugin"
/**
 * [[publicFormBuilder],[pprivateFormBuilder]]
 */
window.CustomFieldsBuilders = window.CustomFieldsBuilders || [];

$(() => {
  $(".awesome-edit-config .proposal_custom_fields_editors").each((_idx, el) => {
    const $container = $(el).closest(".proposal_custom_fields_container")
    const key = $container.data("key");
    window.CustomFieldsBuilders.push($container.find(".proposal_custom_fields_editor").map((_idx, $editor) => {
      const editorKey = $(el).data("key")
      // DOCS: https://formbuilder.online/docs
      return {
        el: el,
        key: key,
        config: {
          i18n: {
            locale: "en-US",
            location: "https://cdn.jsdelivr.net/npm/formbuilder-languages@1.1.0/"
          },
          formData: $(`input[name="config[${editorKey}][${key}]"]`).val(),
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
      }
    }));
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
    window.CustomFieldsBuilders.forEach((form) => {
      $(document).trigger("formBuilder.create", [0, form]);
    })
  }

  $("form.awesome-edit-config").on("submit", () => {
    window.CustomFieldsBuilders.forEach((builder) => {
      const publicBuilder = builder[0];
      const privateBuilder = builder[1];
      // I think this part needs a builder loop for each input
      $(`input[name="config[proposal_custom_fields][${builder.key}]"]`).val(publicBuilder.instance.actions.getData("json"));
      $(`input[name="config[private_proposal_custom_fields][${builder.key}]"]`).val(privateBuilder.instance.actions.getData("json"));
    });
  });
});

