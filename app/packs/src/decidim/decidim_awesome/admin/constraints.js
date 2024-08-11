$(() => {
  const $modal = $("#constraintsModal");
  if (!$modal.length) {
    return;
  }

  $(".decidim_awesome-form").on("click", ".constraints-editor .add-condition,.constraints-editor .edit-condition", (evt) => {
    evt.preventDefault();
    console.log("click", evt.target);
    const $this = $(evt.target)
    const url = $this.attr("href") || $this.data("constraints-url");
    const $callout = $this.closest(".constraints-editor").find(".callout");
    $callout.hide();
    $callout.removeClass("alert success");
    $modal.find(".modal-content").html("");
    $modal.addClass("loading");
    $modal.data("url", url);
    $modal.foundation("open");
    $modal.find(".modal-content").load(url, () => {
      $modal.removeClass("loading");
    });
  });

  // Custom event listener to reload the modal if needed
  document.body.addEventListener("constraint:change", (evt) => {
    const vars = evt.detail.map((setting) => `${setting.key}=${setting.value}`);
    const url = `${$modal.data("url")}&${vars.join("&")}`;
    // console.log("constraint:change vars:", vars, "url:", url)
    $modal.addClass("loading");
    $modal.find(".modal-content").load(url, () => {
      $modal.removeClass("loading");
    });
  });

  // Rails AJAX events
  document.body.addEventListener("ajax:error", (responseText) => {
    // console.log("ajax:error", responseText)
    const $container = $(`.constraints-editor[data-key="${responseText.detail[0].key}"]`)
    const $callout = $container.find(".callout");
    $callout.show();
    $callout.contents("p").html(`${responseText.detail[0].message}: <strong>${responseText.detail[0].error}</strong>`);
    $callout.addClass("alert");
  });

  document.body.addEventListener("ajax:success", (responseText) => {
    // console.log("ajax:success", responseText)
    const $container = $(`.constraints-editor[data-key="${responseText.detail[0].key}"]`)
    const $callout = $container.find(".callout");
    $modal.foundation("close");
    $callout.show();
    $callout.contents("p").html(responseText.detail[0].message);
    $callout.addClass("success");
    // reconstruct list
    $container.replaceWith(responseText.detail[0].html);
  });
});
