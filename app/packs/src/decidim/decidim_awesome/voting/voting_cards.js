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
    return JSON.parse(localStorage.getItem("hideTreeFlagsModalHelp") || "{}");
  };

  const isChecked = () => {
    return storage()[check.value];
  };

  const saveState = (val) => {
    const show = storage();
    show[check.value] = val;
    localStorage.setItem("hideTreeFlagsModalHelp", JSON.stringify(show));
  };

  const showModal = () => {
    console.log("showModal", isChecked(), modal, window.Decidim.currentDialogs[modal.id].isOpen);
    if (isChecked() || window.Decidim.currentDialogs[modal.id].isOpen) {
      return false;
    }
    return true;
  };

  const bindVoteActions = () => {
    document.querySelectorAll(".awesome-voting-card .vote-action").forEach((el) => {
      el.addEventListener("click", (evt) => {
        console.log("clicking", showModal());
        if (showModal()) {
          evt.stopPropagation();
          evt.preventDefault();
          check.checked = isChecked();
          modal.action = evt.currentTarget;
          card.classList = evt.currentTarget.classList;
          console.log("clicked", evt.currentTarget);
          if (evt.currentTarget.children.length > 1) {
            card.innerHTML = `${evt.currentTarget.children[1].outerHTML}<p class="vote-label">${evt.currentTarget.children[1].children[0].textContent}</p>`;
          } else if (card.classList.contains("button")) {
            card.classList.remove("button");
            card.innerHTML = `<p class="vote-label">${evt.currentTarget.title}</p>`;
          } else {
            card.innerHTML = `<p class="vote-label">${evt.currentTarget.textContent}</p>`;
          }
          window.Decidim.currentDialogs[modal.id].open();
        } else {
          console.log("adding loading", evt.currentTarget, evt.target)
          evt.currentTarget.closest(".voting-voting_cards").classList.add("loading");
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

  document.body.addEventListener("ajax:success", () => 
    bindVoteActions());
});
