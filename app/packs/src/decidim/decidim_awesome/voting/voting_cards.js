document.addEventListener("DOMContentLoaded", () => {
  const signOutLink = document.querySelector('[href="/users/sign_out"]');

  if (!signOutLink) {
    return;
  }

  const storage = () => {
    return JSON.parse(localStorage.getItem("awesome_voting_cards_hide_modal") || "{}");
  };

  const saveState = (checkboxValue, val) => {
    const show = storage();
    show[checkboxValue] = val;
    localStorage.setItem("awesome_voting_cards_hide_modal", JSON.stringify(show));
  };

  // Use event delegation to avoid duplicate handlers after AJAX updates
  document.body.addEventListener("click", (evt) => {
    const voteAction = evt.target.closest(".awesome-voting-card .vote-action");

    if (!voteAction) {
      return;
    }

    // If element already has data-dialog-open, let Decidim handle it
    if (voteAction.hasAttribute("data-dialog-open")) {
      return;
    }

    const clickedContainer = voteAction.closest(".awesome-voting-card[data-proposal-id]") || voteAction.closest(".voting-voting_cards[data-proposal-id]");

    if (!clickedContainer) {
      return;
    }

    const clickedProposalId = clickedContainer.dataset.proposalId;
    const clickedModalId = `voting-cards-modal-help-${clickedProposalId}`;
    // Find ALL modals (AJAX may create duplicates)
    const allClickedModals = document.querySelectorAll(`[data-dialog="${clickedModalId}"]`);
    // Use the LAST one (most recent from AJAX)
    const clickedModal = allClickedModals[allClickedModals.length - 1];

    if (!clickedModal) {
      return;
    }

    const clickedCard = clickedModal.querySelector(".current-choice .vote-card");
    const clickedCheck = clickedModal.querySelector('[id^="voting_cards-skip_help"]');

    if (!clickedCard || !clickedCheck) {
      return;
    }

    const isChecked = storage()[clickedCheck.value];
    const isOpen = window.Decidim.currentDialogs[clickedModal.id]?.isOpen;
    const shouldShowModal = !isChecked && !isOpen;

    // If modal already open, don't intercept - let the AJAX request go through
    if (isOpen) {
      return;
    }

    if (shouldShowModal) {
      evt.stopPropagation();
      evt.preventDefault();

      clickedModal.storedAction = voteAction;

      clickedCheck.checked = isChecked || false;

      // Clear previous content first but keep vote-card class
      clickedCard.className = "vote-card";
      clickedCard.innerHTML = "";

      voteAction.classList.forEach(cls => clickedCard.classList.add(cls));
      if (voteAction.children.length > 1) {
        const content = `${voteAction.children[1].outerHTML}<span class="vote-label">${voteAction.children[1].children[0].textContent}</span>`;
        clickedCard.innerHTML = content;
      } else if (clickedCard.classList.contains("button")) {
        clickedCard.classList.remove("button");
        const content = `<span class="vote-label">${voteAction.title}</span>`;
        clickedCard.innerHTML = content;
      } else {
        const content = `<span class="vote-label">${voteAction.textContent}</span>`;
        clickedCard.innerHTML = content;
      }

      if (shouldShowModal) {
        window.Decidim.currentDialogs[clickedModal.id].open();
      }
    } else {
      if (clickedContainer) {
        clickedContainer.classList.add("loading");
      }
    }
  });

  // Initialize all modals on the page (use data-dialog selector to avoid -content wrappers)
  const allModals = document.querySelectorAll('[data-dialog^="voting-cards-modal-help-"]');

  allModals.forEach((modalEl) => {
    const check = modalEl.querySelector('[id^="voting_cards-skip_help"]');
    if (check) {
      check.addEventListener("change", () => {
        saveState(check.value, check.checked);
      });
    }

    const proceedButton = modalEl.querySelector(".vote-action");
    if (proceedButton) {
      proceedButton.addEventListener("click", () => {
        if (modalEl.storedAction) {
          modalEl.storedAction.click();
          setTimeout(() => {
            if (window.Decidim.currentDialogs[modalEl.id]) {
              window.Decidim.currentDialogs[modalEl.id].close();
            }
          });
        }
      });
    }
  });
});
