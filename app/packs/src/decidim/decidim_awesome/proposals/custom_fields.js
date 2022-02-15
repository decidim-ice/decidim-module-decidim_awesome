import CustomFieldsRenderer from "src/decidim/decidim_awesome/forms/custom_fields_renderer"

window.DecidimAwesome.CustomFieldsRenderer = window.DecidimAwesome.CustomFieldsRenderer || new CustomFieldsRenderer();

$(() => {
  // use admin multilang specs if exists
  let $el = $("proposal_custom_field:first", ".tabs-title.is-active");
  $el = $el.length
    ? $el
    : $(".proposal_custom_field:first");
  window.DecidimAwesome.CustomFieldsRenderer.init($el);

  window.DecidimAwesome.CustomFieldsRenderer.$container.closest("form").on("submit", (e) => {
    if (e.target.checkValidity()) {
      // save current editor
      window.DecidimAwesome.CustomFieldsRenderer.storeData();
    } else {
      e.preventDefault();
      e.target.reportValidity();
    }
  });
});
