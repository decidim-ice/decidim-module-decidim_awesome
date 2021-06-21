// = require_self

/**
 * When switching tabs in i18n fields, autofocus on the markdown if exists
 */
$(() => {
  // Event launched by foundation
  $("[data-tabs]").on("change.zf.tabs", (event) => {
    const $container = $(event.target).closest(".label--tabs").next(".tabs-content").find(".tabs-panel.is-active");
    let $input = $container.find('[name="faker-inscrybmde"]');
    if ($input.length > 0) {
      $input[0].InscrybMDE.codemirror.refresh();
    }
  });
});
