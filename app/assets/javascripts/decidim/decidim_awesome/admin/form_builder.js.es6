// = require jquery-ui.min
// = require form-builder.min
// = require_self

$(() => {
  $(".awesome-edit-config .proposal-custom-field-editor").each((_idx, el) => {
    const key = $(el).closest(".proposal-custom-field").data("key");
    const $spec = $("#proposal-custom-field-spec-"+  key);
    // console.log($spec)
    const $builder = $(el).formBuilder({
      formData: $spec.val(),
      disableFields: ['button', 'file'],
      disabledActionButtons: ['save', 'data', 'clear'],
      disabledAttrs: [
        'access',
        'className'
      ]
    });
    $(el).data("builder", $builder);
  });

  $("form.awesome-edit-config").on("submit", (e) => {
    // e.preventDefault();
    $(".awesome-edit-config .proposal-custom-field-editor").each((_dx, el) => {
      const $builder = $(el).data("builder");
      const key = $(el).closest(".proposal-custom-field").data("key");
      const $spec = $("#proposal-custom-field-spec-" +  key);
      // console.log($builder)
      $spec.val($builder.actions.getData("json"));
    });
  });
});

