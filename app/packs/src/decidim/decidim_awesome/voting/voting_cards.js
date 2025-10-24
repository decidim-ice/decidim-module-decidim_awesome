document.addEventListener("DOMContentLoaded", () => {
  const votingCards = document.querySelector(".voting-voting_cards");
  const modal = document.getElementById("voting-cards-modal-help");
  const signOutLink = document.querySelector('[href="/users/sign_out"]');

  if (!votingCards || !modal || !signOutLink) {
    return;
  }

  const card = modal.querySelector(".current-choice .vote-card");
  const check = document.getElementById("voting_cards-skip_help");

  const storage = () => {
    return JSON.parse(localStorage.getItem("awesome_voting_cards_hide_modal") || "{}");
  };

  const isChecked = () => {
    return storage()[check.value];
  };

  const saveState = (val) => {
    const show = storage();
    show[check.value] = val;
    localStorage.setItem("awesome_voting_cards_hide_modal", JSON.stringify(show));
  };

  const showModal = () => {
    if (isChecked() || window.Decidim.currentDialogs[modal.id].isOpen) {
      return false;
    }
    return true;
  };

  const bindVoteActions = () => {
    document.querySelectorAll(".awesome-voting-card .vote-action").forEach((el) => {
      el.addEventListener("click", (evt) => {
        if (evt.currentTarget.hasAttribute("data-dialog-open")) {
          return;
        }

        if (showModal()) {
          evt.stopPropagation();
          evt.preventDefault();
          check.checked = isChecked();
          modal.action = evt.currentTarget;
          card.classList = evt.currentTarget.classList;
          if (evt.currentTarget.children.length > 1) {
            card.innerHTML = `${evt.currentTarget.children[1].outerHTML}<span class="vote-label">${evt.currentTarget.children[1].children[0].textContent}</span>`;
          } else if (card.classList.contains("button")) {
            card.classList.remove("button");
            card.innerHTML = `<span class="vote-label">${evt.currentTarget.title}</span>`;
          } else {
            card.innerHTML = `<span class="vote-label">${evt.currentTarget.textContent}</span>`;
          }
          window.Decidim.currentDialogs[modal.id].open();
        } else {
          const container = evt.currentTarget.closest(".voting-voting_cards") || evt.currentTarget.closest(".awesome-voting-card");
          if (container) {
            container.classList.add("loading");
          }
        }
      });
    });
  };

  check.addEventListener("change", () => {
    saveState(check.checked);
  });

  modal.querySelector(".vote-action").addEventListener("click", () => {
    modal.action.click();
    setTimeout(() => window.Decidim.currentDialogs[modal.id].close());
  });

  bindVoteActions();

  // re-bind vote actions after AJAX events (due the use of Rails helper remote=treu)
  document.body.addEventListener("ajax:success", () => bindVoteActions());
});
