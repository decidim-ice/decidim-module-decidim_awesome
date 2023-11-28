$(() => {
  // Custom event listener to reload the modal if needed
  document.body.addEventListener("constraint:change", (evt) => {
    // Identify the modal element to be updated
    const [{ modalId }] = evt.detail;
    const modal = window.Decidim.currentDialogs[modalId];
    const { dialogRemoteUrl } = modal.openingTrigger.dataset;

    // Prepare parameters to request the modal content again, but updated based on the user selections
    const vars = evt.detail.map((setting) => `${setting.key}=${setting.value}`);
    const url = `${dialogRemoteUrl}&${vars.join("&")}`;

    // Replace only the "-content" markup
    $(modal.dialog.firstElementChild).load(url);
  });

  // Rails AJAX events
  document.body.addEventListener("ajax:error", (responseText) => {
    const $container = $(
      `.constraints-editor[data-key="${responseText.detail[0].key}"]`
    );
    const $callout = $container.find(".flash");
    $callout.show();
    $callout.
      find("p").
      html(
        `${responseText.detail[0].message}: <strong>${responseText.detail[0].error}</strong>`
      );
    $callout.addClass("alert");
  });

  document.body.addEventListener("ajax:success", (responseText) => {
    // console.log("ajax:success", responseText);
    const $container = $(
      `.constraints-editor[data-key="${responseText.detail[0].key}"]`
    );
    const $callout = $container.find(".flash");

    $callout.show();
    $callout.find("p").html(responseText.detail[0].message);
    $callout.addClass("success");
    // reconstruct list
    $container.replaceWith(responseText.detail[0].html);
  });
});
