require("formBuilder/dist/form-builder.min.js")
import "src/decidim/decidim_awesome/forms/rich_text_plugin"
/**
 * [[publicFormBuilder],[pprivateFormBuilder]]
 */
window.CustomFieldsBuilders = window.CustomFieldsBuilders || [];

$(() => {
  $(".awesome-edit-config .proposal_custom_fields_container").each((_idx, el) => {
    console.log("Found one editor, setup public/private formbuilder")
    const $container = $(el);
    const key = $container.data("key");
    const optionsPair=[]
    $container.find(".proposal_custom_fields_editor").each((idx, editor) => {
      const editorKey = $(editor).data("key")
      // DOCS: https://formbuilder.online/docs
      optionsPair.push({
        el: editor,
        key: `${key}:${idx}`,
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
      })
    })
    console.log({optionsPair})
    window.CustomFieldsBuilders.push(optionsPair);
  });


  $(document).on("formBuilder.create", (_event, idx, list) => {
    if (!list[idx]) {
      console.log("Does not exists", {idx, list})
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
      if (idx < list.length - 1) {
        $(document).trigger("formBuilder.create", [idx + 1, list]);
      }
    });
  });

  if (window.CustomFieldsBuilders.length > 0) {
    window.CustomFieldsBuilders.forEach((privatePublicEditors) => {
      $(document).trigger("formBuilder.create", [0, privatePublicEditors]);
    })
  }

  $("form.awesome-edit-config").on("submit", () => {
    window.CustomFieldsBuilders.forEach(([publicForm, privateForm]) => {
      // I think this part needs a builder loop for each input
      $(`input[name="config[proposal_custom_fields][${publicForm.key}]"]`).val(publicForm.instance.actions.getData("json"));
      $(`input[name="config[private_proposal_custom_fields][${privateForm.key}]"]`).val(privateForm.instance.actions.getData("json"));
    });
  });
});

