// = require jquery-ui.min
// = require form-builder.min
// = require_self

$(() => {
  let fbList = [];

  $(".awesome-edit-config .proposal-custom-field-editor").each((_idx, el) => {
    const key = $(el).closest(".proposal-custom-field").data("key");
    fbList.push({
      el: el,
      key: key,
      config: {
        formData: $("#proposal-custom-field-spec-" +  key).val(),
        disableFields: ['button', 'file'],
        disabledActionButtons: ['save', 'data', 'clear'],
        disabledAttrs: [
          'access',
          'inline',
          'className'
        ],
        disabledSubtypes: {
          // text: ['password','color'],
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
        i++;
        initFormBuilder(i);
      });
    } else {
      return;
    }
  };
  initFormBuilder(0);


  $("form.awesome-edit-config").on("submit", (e) => {
    // e.preventDefault();
    fbList.forEach((builder) =>{
      $("#proposal-custom-field-spec-" +  builder.key).val(builder.instance.actions.getData("json"));
    });
  });
});

