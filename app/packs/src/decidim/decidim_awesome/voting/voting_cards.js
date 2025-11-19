document.addEventListener("DOMContentLoaded", () => {
  if (!document.querySelector('[href="/users/sign_out"]')) {
    return;
  }

  const STORAGE_KEY = "awesome_voting_cards_hide_modal";
  const MODAL_ID = "voting-cards-help-modal";

  const getStorage = () => JSON.parse(localStorage.getItem(STORAGE_KEY) || "{}");
  const saveStorage = (key, val) => localStorage.setItem(STORAGE_KEY, JSON.stringify({ ...getStorage(), [key]: val }));
  const findContainer = (el) => el.closest(".awesome-voting-card[data-proposal-id], .voting-voting_cards[data-proposal-id]");
  const isModalOpen = () => window.Decidim.currentDialogs[MODAL_ID]?.isOpen;

  const modal = document.querySelector(`[data-dialog="${MODAL_ID}"]`);
  if (!modal) {
    return;
  }

  const voteCard = modal.querySelector(".current-choice .vote-card");
  const checkbox = modal.querySelector('[id^="voting_cards-skip_help"]');
  if (!voteCard || !checkbox) {
    return;
  }

  const updateCard = (action) => {
    voteCard.className = "vote-card";
    action.classList.forEach((cls) => voteCard.classList.add(cls));

    let content = "";
    if (action.children.length > 1) {
      const child = action.children[1];
      content = `${child.outerHTML}<span class="vote-label">${child.children[0].textContent}</span>`;
    } else if (voteCard.classList.contains("button")) {
      voteCard.classList.remove("button");
      content = `<span class="vote-label">${action.title}</span>`;
    } else {
      content = `<span class="vote-label">${action.textContent}</span>`;
    }
    voteCard.innerHTML = content;
  };

  checkbox.addEventListener("change", () => saveStorage(checkbox.value, checkbox.checked));

  modal.querySelector(".vote-action").addEventListener("click", () => {
    if (!modal.storedAction) {
      return;
    }

    const container = findContainer(modal.storedAction);
    if (container) {
      container.classList.add("loading");
    }

    modal.storedAction.click();
    setTimeout(() => window.Decidim.currentDialogs[MODAL_ID]?.close());
  });

  document.body.addEventListener("click", (evt) => {
    const voteAction = evt.target.closest(".awesome-voting-card .vote-action");
    if (!voteAction || voteAction.hasAttribute("data-dialog-open")) {
      return;
    }

    const container = findContainer(voteAction);
    if (!container) {
      return;
    }

    const shouldShow = !getStorage()[checkbox.value] && !isModalOpen();

    if (shouldShow) {
      evt.stopPropagation();
      evt.preventDefault();
      modal.storedAction = voteAction;
      checkbox.checked = false;
      updateCard(voteAction);
      window.Decidim.currentDialogs[MODAL_ID].open();
    } else {
      container.classList.add("loading");
    }
  });
});
