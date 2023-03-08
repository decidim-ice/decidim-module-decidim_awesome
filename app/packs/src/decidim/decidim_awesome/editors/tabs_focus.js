
const customFieldRenderers = window.DecidimAwesome.CustomFieldsRenderer || [];
/**
 * When switching tabs in i18n fields, autofocus on the markdown if exists
 */
$(() => {
  // Event launched by foundation
  $("[data-tabs]").on("change.zf.tabs", (event) => {
    const $container = $(event.target).closest(".label--tabs").next(".tabs-content").find(".tabs-panel.is-active");
    // fix inscrybmde if present
    let $input = $container.find('[name="faker-inscrybmde"]');
    if ($input.length > 0) {
      $input[0].InscrybMDE.codemirror.refresh();
    }
    // fix custom fields if present
    $inputs = $container.find(".proposal_custom_field");
    if ($inputs.length > 0) {
      customFieldRenderers.forEach(r => r.storeData());
      $inputs.each((input, index) => {
        // saves current data to the hidden field for the lang
        // init the current language
        customFieldRenderers[index].init($(input))
      })
     
    }
  });
});
