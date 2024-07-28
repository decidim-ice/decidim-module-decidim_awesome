import CustomFieldsRenderer from "src/decidim/decidim_awesome/forms/custom_fields_renderer"

$(() => {
  window.DecidimAwesome.CustomFieldsRenderer = window.DecidimAwesome.CustomFieldsRenderer || new CustomFieldsRenderer();
  window.DecidimAwesome.PrivateCustomFieldsRenderer = window.DecidimAwesome.PrivateCustomFieldsRenderer || new CustomFieldsRenderer();

  // use admin multilang specs if exists
  const $public = $(".proposal_custom_field:first");
  const $private = $(".proposal_custom_field.proposal_custom_field--private_body:first");
  let $form = null;
  if ($public.length) {
    window.DecidimAwesome.CustomFieldsRenderer.init($public);
    $form = window.DecidimAwesome.CustomFieldsRenderer.$element.closest("form");
  }
  if ($private.length) {
    window.DecidimAwesome.PrivateCustomFieldsRenderer.init($private);
    if (!$form) {
      $form = window.DecidimAwesome.PrivateCustomFieldsRenderer.$element.closest("form");
    }
  }

  if ($form) {
    $form.on("submit", (evt) => {
      if (evt.target.checkValidity()) {
        // save current editors
        if ($public.length) {
          window.DecidimAwesome.CustomFieldsRenderer.storeData();
        }
        if ($private.length) {
          window.DecidimAwesome.PrivateCustomFieldsRenderer.storeData();
        }
      } else {
        evt.preventDefault();
        evt.target.reportValidity();
      }
    });
  }
});
