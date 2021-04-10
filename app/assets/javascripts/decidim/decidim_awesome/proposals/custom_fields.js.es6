// = require form-render.min
// = require_self

$(() => {
  $(".proposal_custom_field").each((_idx, element) => {
    const data = $(element).data("spec");
    const formRenderOps = {
      formData: data
    };
    console.log(data);

    $(element).formRender(formRenderOps);
  });
});
