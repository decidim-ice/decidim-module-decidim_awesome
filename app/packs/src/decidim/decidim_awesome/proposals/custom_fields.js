import CustomFieldsBuilder from "src/decidim/decidim_awesome/forms/custom_fields_builder"

window.DecidimAwesome.FormRenderBuilder = window.DecidimAwesome.FormRenderBuilder || new CustomFieldsBuilder();

$(() => {
  // use admin multilang specs if exists
  let $el = $("proposal_custom_field:first", ".tabs-title.is-active");
  $el = $el.length ? $el : $(".proposal_custom_field:first");
  DecidimAwesome.FormRenderBuilder.init($el);

  DecidimAwesome.FormRenderBuilder.$container.closest("form").on("submit", (e) => {
    if(e.target.checkValidity()) {
      // save current editor
      DecidimAwesome.FormRenderBuilder.storeData();
    } else {
      e.preventDefault();
      e.target.reportValidity();
    }
  });
});
