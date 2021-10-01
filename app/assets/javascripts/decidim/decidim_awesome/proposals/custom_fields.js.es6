// = require decidim/decidim_awesome/forms/custom_fields_builder
// = require form-render.min
// = require_self

let FormRenderBuilder = new CustomFieldsBuilder();

$(() => {
  // use admin multilang specs if exists
  let $el = $("proposal_custom_field:first", ".tabs-title.is-active");
  $el = $el.length ? $el : $(".proposal_custom_field:first");
  FormRenderBuilder.init($el);

  FormRenderBuilder.$container.closest("form").on("submit", (e) => {
    if(e.target.checkValidity()) {
      // save current editor
      FormRenderBuilder.storeData();
    } else {
      e.preventDefault();
      e.target.reportValidity();
    }
  });
});
