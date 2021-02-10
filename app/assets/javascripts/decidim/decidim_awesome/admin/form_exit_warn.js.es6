// = require_self

$(() => {
  const $form = $("form.awesome-edit-config");
  if ($form.length > 0) {
    $form.find("input, textarea, select").on("change", () => {
      $form.data("changed", true);
    });

    const safePath = $form.data("safe-path").split("?")[0];
    $(document).on("click", "a", (event) => {
      window.exitUrl = event.currentTarget.href;
    });
    $(document).on("submit", "form", (event) => {
      window.exitUrl = event.currentTarget.action;
    });

    window.onbeforeunload = () => {
      const exitUrl = window.exitUrl;
      const hasChanged = $form.data("changed");
      window.exitUrl = null;

      if (!hasChanged || (exitUrl && exitUrl.includes(safePath))) {
        return null;
      }

      return "";
    }
  }
});
