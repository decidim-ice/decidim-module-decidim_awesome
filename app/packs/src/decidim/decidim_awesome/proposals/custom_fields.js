import CustomFieldsRenderer from "src/decidim/decidim_awesome/forms/custom_fields_renderer"

window.DecidimAwesome.CustomFieldsRenderer = window.DecidimAwesome.CustomFieldsRenderer || new CustomFieldsRenderer();

$(() => {
  // use admin multilang specs if exists
  let $el = $("proposal_custom_field:first", ".tabs-title.is-active");
  if (!$el.length) {
    $el = $(".proposal_custom_field:first");
  }
  window.DecidimAwesome.CustomFieldsRenderer.init($el);

  window.DecidimAwesome.CustomFieldsRenderer.$container.closest("form").on("submit", (evt) => {
    if (evt.target.checkValidity()) {
      // save current editor
      window.DecidimAwesome.CustomFieldsRenderer.storeData();
    } else {
      evt.preventDefault();
      evt.target.reportValidity();
    }
  });
});

window.DecidimAwesome.PrivateCustomFieldsRenderer = window.DecidimAwesome.PrivateCustomFieldsRenderer || new CustomFieldsRenderer();

$(() => {
  // use admin multilang specs if exists
  let $el = $("private_proposal_custom_field:first", ".tabs-title.is-active");
  if (!$el.length) {
    $el = $(".private_proposal_custom_field:first");
  }
  window.DecidimAwesome.PrivateCustomFieldsRenderer.init($el);

  window.DecidimAwesome.PrivateCustomFieldsRenderer.$container.closest("form").on("submit", (evt) => {
    if (evt.target.checkValidity()) {
      // save current editor
      window.DecidimAwesome.PrivateCustomFieldsRenderer.storeData();
    } else {
      evt.preventDefault();
      evt.target.reportValidity();
    }
  });
});
