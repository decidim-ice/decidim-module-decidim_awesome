import "src/decidim/decidim_awesome/editors/quill_editor"
import "src/decidim/decidim_awesome/forms/rich_text_plugin"
import "jquery-ui/ui/widgets/sortable"

let formBuilderList = [];

$(() => {
  $(".awesome-edit-config .proposal_custom_fields_editor").each((_idx, el) => {
    const key = $(el).closest(".proposal_custom_fields_container").data("key");
    // DOCS: https://formbuilder.online/docs
    formBuilderList.push({
      el: el,
      key: key,
      config: {
        i18n: {
          locale: 'en-US',
          location: 'https://cdn.jsdelivr.net/npm/formbuilder-languages@1.1.0/'
        },
        formData: $(`input[name="config[proposal_custom_fields][${key}]"]`).val(),
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
          text: ['color'], // default color as it generate hashtags in decidim (TODO: fix hashtag generator with this)
          // disable default wysiwyg editors as they present problems
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

  if(formBuilderList.length) {
    $(document).trigger("formBuilder.create", [0, formBuilderList]);
  }

  $("form.awesome-edit-config").on("submit", () => {
    formBuilderList.forEach((builder) =>{
      $(`input[name="config[proposal_custom_fields][${builder.key}]"]`).val(builder.instance.actions.getData("json"));
    });
  });
});

