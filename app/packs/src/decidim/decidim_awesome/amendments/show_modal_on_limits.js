document.addEventListener("DOMContentLoaded", () => {
  const modalId = "LimitAmendmentsModal";
  const modalEl = document.getElementById(modalId);
  const limitAmendments = modalEl && JSON.parse(modalEl.dataset.limitAmendments);

  if (!limitAmendments || document.querySelector('a[href^="/users/sign_in"]')) {
    return;
  }

  modalEl.querySelectorAll("a").forEach((aEl) => {
    aEl.addEventListener("click", () => {
      window.Decidim.currentDialogs[modalId].close();
    });
  });

  document.addEventListener("click", (event) => {
    const target = event.target.closest("#amend-button");
    if (!target) {
      return;
    }

    const modal = window.Decidim.currentDialogs[modalId];
    if (!modal) {
      return;
    }

    event.preventDefault();
    event.stopPropagation();
    modal.open();
  });
});
