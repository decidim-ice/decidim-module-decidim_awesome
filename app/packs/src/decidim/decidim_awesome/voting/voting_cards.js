document.addEventListener("DOMContentLoaded", () => {
  const signOutLink = document.querySelector('[href="/users/sign_out"]');

  if (!signOutLink) {
    return;
  }

  // Constants
  const STORAGE_KEY = "awesome_voting_cards_hide_modal";
  const VOTING_MODAL_ID = "voting-cards-help-modal";
  const SELECTORS = {
    voteAction: ".awesome-voting-card .vote-action",
    containers: [".awesome-voting-card[data-proposal-id]", ".voting-voting_cards[data-proposal-id]"],
    globalModal: `[data-dialog="${VOTING_MODAL_ID}"]`,
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

  // Find global modal elements
  const findModalElements = () => {
    const modal = document.querySelector(SELECTORS.globalModal);

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
  const shouldShowModal = (checkbox) => {
    const isChecked = getStorage()[checkbox.value];
    const isOpen = window.Decidim.currentDialogs[VOTING_MODAL_ID]?.isOpen;
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

    const elements = findModalElements();

    if (!elements) {
      return;
    }

    const { modal, card, checkbox } = elements;

    // If modal already open, don't intercept - let the AJAX request go through
    if (window.Decidim.currentDialogs[VOTING_MODAL_ID]?.isOpen) {
      return;
    }

    if (shouldShowModal(checkbox)) {
      evt.stopPropagation();
      evt.preventDefault();

      modal.storedAction = voteAction;
      checkbox.checked = false;
      updateVoteCardContent(card, voteAction);
      window.Decidim.currentDialogs[VOTING_MODAL_ID].open();
    } else {
      container.classList.add("loading");
    }
  };

  // Initialize modal handlers
  const initModalHandlers = () => {
    const modal = document.querySelector(SELECTORS.globalModal);
    if (!modal) {
      return;
    }

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
            window.Decidim.currentDialogs[VOTING_MODAL_ID]?.close();
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

  // Initialize global modal
  initModalHandlers();
});
