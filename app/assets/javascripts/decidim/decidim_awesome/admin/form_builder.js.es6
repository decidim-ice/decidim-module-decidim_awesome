// = require jquery-ui.min
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
          // disable wysiwg editors as they present problems
          // TODO: create custom type to integrate decidim Quill Editor
          textarea: ['tinymce', 'quill']
        },
      },
      instance: null
    });
  });

  const initFormBuilder = (i) => {
    if (i < fbList.length) {
      $(fbList[i].el).formBuilder(fbList[i].config).promise.then(function(res){
        fbList[i].instance = res;
        // Attach to DOM
        fbList[i].el.FormBuilder = res;
        // remove spinner
        $(fbList[i].el).find(".loading-spinner").remove();
        // for external use
        $(document).trigger("formBuilder.created", res);
        initFormBuilder(i + 1);
      });
    } else {
      return;
    }
  };
  initFormBuilder(0);


  $("form.awesome-edit-config").on("submit", () => {
    // e.preventDefault();
    fbList.forEach((builder) =>{
      $("#proposal-custom-field-spec-" +  builder.key).val(builder.instance.actions.getData("json"));
    });
  });
});

