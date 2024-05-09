document.addEventListener("DOMContentLoaded", function() {
  const modal = document.getElementById("LimitAmendmentsModal");
  const closeModalButtons = modal.querySelectorAll("[data-dialog-close]");

  if (!modal || document.querySelector(".sign-out-link") === null) {
    return;
  }

  /**
   * Determines if the modal should be displayed based on its current state and data attributes.
   * @returns {boolean} True if the modal should be displayed, otherwise false.
   */
  const showModal = function() {
    if (!modal.classList.contains("hidden")) {
      return false;
    }

    if (modal.dataset.limitAmendments) {
      return true;
    }

    return false;
  }

  closeModalButtons.forEach((button) => {
    button.addEventListener("click", function() {
      modal.classList.add("hidden");
    });
  });

  const amendButtons = document.querySelectorAll(".card__amend-button .amend_button_card_cell");

  amendButtons.forEach((button) => {
    button.addEventListener("click", function(event) {
      if (showModal()) {
        event.preventDefault();
        event.stopPropagation();
        modal.classList.remove("hidden");
      }
    });
  });
});
