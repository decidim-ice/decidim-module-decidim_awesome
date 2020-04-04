// = require_self

$(() => {
  const $modal = $('#constraintsModal');
  if(!$modal.length) return;

  $(".decidim_awesome-form").on("click", ".constraints-editor .add-condition,.constraints-editor .edit-condition", (e) => {
    e.preventDefault();
    const $this = $(e.target)
    const url = $this.attr("href");
    const $callout = $this.closest(".constraints-editor").find(".callout");
    $callout.hide();
    $callout.removeClass('alert success');
    $modal.find('.modal-content').html('');
    $modal.addClass('loading').foundation('open');
    $modal.data("url", url);
    $modal.find('.modal-content').load(url, () => {
      $modal.removeClass('loading');
    });
  });

  // Custom event listener to reload the modal if needed
  document.body.addEventListener("constraint:change", (e) => {
    const url = $modal.data("url") + `&${e.detail.key}=${e.detail.value}`
    $modal.addClass('loading');
    $modal.find('.modal-content').load(url, () => {
      $modal.removeClass('loading');
    });
  });

  // Rails AJAX events
  document.body.addEventListener('ajax:error', (responseText) => {
    const $container = $(`.constraints-editor[data-key="${responseText.detail[0].key}"]`)
    const $callout = $container.find(".callout");
    $callout.show();
    $callout.contents('p').html(responseText.detail[0].message + ": <strong>" + responseText.detail[0].error + "</strong>");
    $callout.addClass('alert');
  });

  document.body.addEventListener('ajax:success', (responseText) => {
    const $container = $(`.constraints-editor[data-key="${responseText.detail[0].key}"]`)
    const $callout = $container.find(".callout");
    $callout.show();
    $callout.contents('p').html(responseText.detail[0].message);
    $callout.addClass('success');
    // reconstruct list
    $container.replaceWith(responseText.detail[0].html);
  });

  document.body.addEventListener('ajax:complete', (xhr, event) => {
    $modal.foundation('close');
  })
});