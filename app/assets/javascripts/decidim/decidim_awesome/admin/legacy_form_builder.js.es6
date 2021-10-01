// = require jquery-ui.min
// = require decidim/decidim_awesome/editors/legacy_quill_editor
// = require decidim/decidim_awesome/forms/rich_text_plugin
// = require form-builder.min
// = require_self

$(() => {
  let fbList = [];

  $(".awesome-edit-config .proposal-custom-field-editor").each((_idx, el) => {
    const key = $(el).closest(".proposal-custom-field").data("key");
    // DOCS: https://formbuilder.online/docs
    fbList.push({
      el: el,
      key: key,
      config: {
        i18n: {
          locale: 'en-US',
          location: 'https://cdn.jsdelivr.net/npm/formbuilder-languages@1.1.0/'
        },
        formData: $("#proposal-custom-field-spec-" +  key).val(),
        disableFields: ['button', 'file'],
        disabledActionButtons: ['save', 'data', 'clear'],
        disabledAttrs: [
          'access',
          'inline',
          'className'
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
          text: ['color'], // TODO: fix hashtag generator with this
          // disable wysiwyg editors as they present problems
          // TODO: create custom type to integrate decidim Quill Editor
          textarea: ['tinymce', 'quill']
        },
      },
      instance: null
    });
  });

  $(document).on("formBuilder.create", (_event, i, list) => {
    if(!list[i]) return;

    $(list[i].el).formBuilder(list[i].config).promise.then(function(res){
      list[i].instance = res;
      // Attach to DOM
      list[i].el.FormBuilder = res;
      // remove spinner
      $(list[i].el).find(".loading-spinner").remove();
      // for external use
      $(document).trigger("formBuilder.created", [list[i]]);
      if(i < list.length) {
        $(document).trigger("formBuilder.create", [i + 1, list]);
      }
    });
  });

  if(fbList.length) {
    $(document).trigger("formBuilder.create", [0, fbList]);
  }

  $("form.awesome-edit-config").on("submit", () => {
    // e.preventDefault();
    fbList.forEach((builder) =>{
      $("#proposal-custom-field-spec-" +  builder.key).val(builder.instance.actions.getData("json"));
    });
  });
});

