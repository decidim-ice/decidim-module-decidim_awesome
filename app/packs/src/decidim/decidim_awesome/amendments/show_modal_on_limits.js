document.addEventListener("DOMContentLoaded", () => {
  const modalId = "LimitAmendmentsModal";
  const modalEl = document.getElementById(modalId);
  const amendButton = document.getElementById("amend-button");
  const limitAmendments = modalEl && JSON.parse(modalEl.dataset.limitAmendments);

  if (!amendButton || !limitAmendments || document.querySelector('a[href^="/users/sign_in"]')) {
    return;
  }

  /**
   * Determines if the modal should be displayed based on its current state and data attributes.
   */
  amendButton.addEventListener("click", (event) => {
    const modal = window.Decidim.currentDialogs[modalId];
    if (modal) {
      event.preventDefault();
      event.stopPropagation();
      modal.open();
    }
  });
});
