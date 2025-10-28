document.addEventListener("DOMContentLoaded", () => {
  const signOutLink = document.querySelector('[href="/users/sign_out"]');

  if (!signOutLink) {
    return;
  }

  // Constants
  const STORAGE_KEY = "awesome_voting_cards_hide_modal";
  const SELECTORS = {
    voteAction: ".awesome-voting-card .vote-action",
    containers: [".awesome-voting-card[data-proposal-id]", ".voting-voting_cards[data-proposal-id]"],
    modal: '[data-dialog^="voting-cards-modal-help-"]',
    voteCard: ".current-choice .vote-card",
    checkbox: '[id^="voting_cards-skip_help"]',
    proceedButton: ".vote-action"
  };

  // Storage helpers
  const getStorage = () => JSON.parse(localStorage.getItem(STORAGE_KEY) || "{}");

  const saveToStorage = (key, value) => {
    const storage = getStorage();
    storage[key] = value;
    localStorage.setItem(STORAGE_KEY, JSON.stringify(storage));
  };

  // Find modal elements for a proposal
  const findModalElements = (proposalId) => {
    const modalId = `voting-cards-modal-help-${proposalId}`;
    // Find ALL modals (AJAX may create duplicates)
    const allModals = document.querySelectorAll(`[data-dialog="${modalId}"]`);
    // Use the LAST one (most recent from AJAX)
    const modal = allModals[allModals.length - 1];

    if (!modal) {
      return null;
    }

    const card = modal.querySelector(SELECTORS.voteCard);
    const checkbox = modal.querySelector(SELECTORS.checkbox);

    return (card && checkbox)
      ? { modal, card, checkbox }
      : null;
  };

  // Update vote card content
  const updateVoteCardContent = (card, action) => {
    // Clear previous content first but keep vote-card class
    card.className = "vote-card";
    card.innerHTML = "";

    action.classList.forEach((cls) => card.classList.add(cls));

    let content = "";
    if (action.children.length > 1) {
      const child = action.children[1];
      content = `${child.outerHTML}<span class="vote-label">${child.children[0].textContent}</span>`;
    } else if (card.classList.contains("button")) {
      card.classList.remove("button");
      content = `<span class="vote-label">${action.title}</span>`;
    } else {
      content = `<span class="vote-label">${action.textContent}</span>`;
    }

    card.innerHTML = content;
  };

  // Check if modal should be shown
  const shouldShowModal = (checkbox, modalId) => {
    const isChecked = getStorage()[checkbox.value];
    const isOpen = window.Decidim.currentDialogs[modalId]?.isOpen;
    return !isChecked && !isOpen;
  };

  // Handle vote action click
  const handleVoteAction = (evt, voteAction) => {
    // If element already has data-dialog-open, let Decidim handle it
    if (voteAction.hasAttribute("data-dialog-open")) {
      return;
    }

    const container = SELECTORS.containers.map((sel) => voteAction.closest(sel)).find(Boolean);
    if (!container) {
      return;
    }

    const proposalId = container.dataset.proposalId;
    const elements = findModalElements(proposalId);

    if (!elements) {
      return;
    }

    const { modal, card, checkbox } = elements;

    // If modal already open, don't intercept - let the AJAX request go through
    if (window.Decidim.currentDialogs[modal.id]?.isOpen) {
      return;
    }

    if (shouldShowModal(checkbox, modal.id)) {
      evt.stopPropagation();
      evt.preventDefault();

      modal.storedAction = voteAction;
      checkbox.checked = false;
      updateVoteCardContent(card, voteAction);
      window.Decidim.currentDialogs[modal.id].open();
    } else {
      container.classList.add("loading");
    }
  };

  // Initialize modal handlers
  const initModalHandlers = (modal) => {
    const checkbox = modal.querySelector(SELECTORS.checkbox);
    if (checkbox) {
      checkbox.addEventListener("change", () => {
        saveToStorage(checkbox.value, checkbox.checked);
      });
    }

    const proceedButton = modal.querySelector(SELECTORS.proceedButton);
    if (proceedButton) {
      proceedButton.addEventListener("click", () => {
        if (modal.storedAction) {
          modal.storedAction.click();
          setTimeout(() => {
            window.Decidim.currentDialogs[modal.id]?.close();
          });
        }
      });
    }
  };

  // Use event delegation to avoid duplicate handlers after AJAX updates
  document.body.addEventListener("click", (evt) => {
    const voteAction = evt.target.closest(SELECTORS.voteAction);
    if (voteAction) {
      handleVoteAction(evt, voteAction);
    }
  });

  // Initialize all modals on the page (use data-dialog selector to avoid -content wrappers)
  document.querySelectorAll(SELECTORS.modal).forEach(initModalHandlers);
});
