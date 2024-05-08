$(() => {
  const $modal = $("#LimitAmendmentsModal");
  if ($modal.length === 0 || $(".sign-out-link").length === 0) {
    return;
  }

  const showModal = () => {
    if ($modal.is(":visible")) {
      return false;
    }

    if ($modal.data("limitAmendments")) {
      return true;
    }

    return false;
  };

  $modal.find("a").on("click", () => {
    $modal.foundation("close");
  });

  $(".card__amend-button").on("click", ".amend_button_card_cell", (evt) => {
    if (showModal())  {
      evt.preventDefault();
      evt.stopPropagation();
      $modal.foundation("open");
    }
  });
});
