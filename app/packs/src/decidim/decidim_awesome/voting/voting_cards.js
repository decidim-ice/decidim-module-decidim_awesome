document.addEventListener("DOMContentLoaded", () => {
  const signOutLink = document.querySelector('[href="/users/sign_out"]');

  if (!signOutLink) {
    return;
  }

  const STORAGE_KEY = "awesome_voting_cards_hide_modal";
  const VOTING_MODAL_ID = "voting-cards-help-modal";
  const SELECTORS = {
    voteAction: ".awesome-voting-card .vote-action",
    containers: [".awesome-voting-card[data-proposal-id]", ".voting-voting_cards[data-proposal-id]"],
    modal: `[data-dialog="${VOTING_MODAL_ID}"]`,
    voteCard: ".current-choice .vote-card",
    checkbox: '[id^="voting_cards-skip_help"]',
    proceedButton: ".vote-action"
  };

  const getStorage = () => JSON.parse(localStorage.getItem(STORAGE_KEY) || "{}");

  const saveToStorage = (key, value) => {
    const storage = getStorage();
    storage[key] = value;
    localStorage.setItem(STORAGE_KEY, JSON.stringify(storage));
  };

  const findContainer = (element) => SELECTORS.containers.map((sel) => element.closest(sel)).find(Boolean);

  const isModalOpen = () => window.Decidim.currentDialogs[VOTING_MODAL_ID]?.isOpen;

  const findModalElements = () => {
    const modal = document.querySelector(SELECTORS.modal);
    if (!modal) {
      return null;
    }

    const card = modal.querySelector(SELECTORS.voteCard);
    const checkbox = modal.querySelector(SELECTORS.checkbox);

    return (card && checkbox)
      ? { modal, card, checkbox }
      : null;
  };

  const updateVoteCardContent = (card, action) => {
    card.className = "vote-card";
    card.innerHTML = "";
    action.classList.forEach((cls) => card.classList.add(cls));

    const getContent = () => {
      if (action.children.length > 1) {
        const child = action.children[1];
        return `${child.outerHTML}<span class="vote-label">${child.children[0].textContent}</span>`;
      }

      if (card.classList.contains("button")) {
        card.classList.remove("button");
        return `<span class="vote-label">${action.title}</span>`;
      }

      return `<span class="vote-label">${action.textContent}</span>`;
    };

    card.innerHTML = getContent();
  };

  const shouldShowModal = (checkbox) => !getStorage()[checkbox.value] && !isModalOpen();

  const handleVoteAction = (evt, voteAction) => {
    if (voteAction.hasAttribute("data-dialog-open")) {
      return;
    }

    const container = findContainer(voteAction);
    if (!container) {
      return;
    }

    const elements = findModalElements();
    if (!elements) {
      return;
    }

    const { modal, card, checkbox } = elements;
    if (isModalOpen()) {
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

  const initModalHandlers = () => {
    const modal = document.querySelector(SELECTORS.modal);
    if (!modal) {
      return;
    }

    const checkbox = modal.querySelector(SELECTORS.checkbox);
    if (checkbox) {
      checkbox.addEventListener("change", () => saveToStorage(checkbox.value, checkbox.checked));
    }

    const proceedButton = modal.querySelector(SELECTORS.proceedButton);
    if (proceedButton) {
      proceedButton.addEventListener("click", () => {
        if (!modal.storedAction) {
          return;
        }

        const container = findContainer(modal.storedAction);
        if (container) {
          container.classList.add("loading");
        }

        modal.storedAction.click();
        setTimeout(() => window.Decidim.currentDialogs[VOTING_MODAL_ID]?.close());
      });
    }
  };

  document.body.addEventListener("click", (evt) => {
    const voteAction = evt.target.closest(SELECTORS.voteAction);
    if (voteAction) {
      handleVoteAction(evt, voteAction);
    }
  });

  initModalHandlers();
});
