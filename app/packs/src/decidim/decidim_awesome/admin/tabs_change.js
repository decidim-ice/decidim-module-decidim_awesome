/**
 * When switching tabs in i18n fields, autofocus on the markdown if exists
 */
$(() => {
  // Event launched by foundation (still there in 0.28)
  $("[data-tabs]").on("change.zf.tabs", (event) => {
    const $container = $(event.target).closest(".label--tabs").next(".tabs-content").find(".tabs-panel.is-active");
    // fix custom fields if present
    const $input = $container.find(".proposal_custom_field:first");
    if ($input.length > 0) {
      // saves current data to the hidden field for the lang
      window.DecidimAwesome.CustomFieldsRenderer.storeData();
      // init the current language
      window.DecidimAwesome.CustomFieldsRenderer.init($input);
    }
  });
});
