import CustomFieldsRenderer from "src/decidim/decidim_awesome/forms/custom_fields_renderer"

$(() => {
  window.DecidimAwesome.CustomFieldsRenderer = window.DecidimAwesome.CustomFieldsRenderer || new CustomFieldsRenderer();

  // use admin multilang specs if exists
  let $el = $("proposal_custom_field:first", ".tabs-title.is-active");
  if (!$el.length) {
    $el = $(".proposal_custom_field:first");
  }
  window.DecidimAwesome.CustomFieldsRenderer.init($el);

  window.DecidimAwesome.CustomFieldsRenderer.$element.closest("form").on("submit", (evt) => {
    if (evt.target.checkValidity()) {
      // save current editor
      window.DecidimAwesome.CustomFieldsRenderer.storeData();
    } else {
      evt.preventDefault();
      evt.target.reportValidity();
    }
  });
});
