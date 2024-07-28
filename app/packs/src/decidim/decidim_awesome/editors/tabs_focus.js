/**
 * When switching tabs in i18n fields, autofocus on the markdown if exists
 */
$(() => {
  const reloadCustomFields = ($input) => {
    // saves current data to the hidden field for the lang
    window.DecidimAwesome.CustomFieldsRenderer.storeData();
    // init the current language
    window.DecidimAwesome.CustomFieldsRenderer.init($input);
  };

  // Event launched by foundation using jQuery (still used in the admin in v0.28, probably removed in the future)
  $("[data-tabs]").on("change.zf.tabs", (event) => {
    const $container = $(event.target).closest(".label--tabs").next(".tabs-content").find(".tabs-panel.is-active");
    // fix custom fields if present
    const $input = $container.find(".proposal_custom_field:first");
    if ($input.length > 0) {
      reloadCustomFields($input);
    }
  });

  // if more than 3 languages, a select is used
  $("#proposal-body-tabs").on("change", (event) => {
    const $container = $($(event.target).val());
    // fix custom fields if present
    const $input = $container.find(".proposal_custom_field:first");
    if ($input.length > 0) {
      reloadCustomFields($input);
    }
  });
});
