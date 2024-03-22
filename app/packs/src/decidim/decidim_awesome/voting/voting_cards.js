document.addEventListener("DOMContentLoaded", function () {
  const votingCards = document.querySelector(".voting-voting_cards");
  const modalHelp = document.getElementById("voting-cards-proposal-modal");
  const signOutLink = document.querySelector(".sign-out-link");

  if (!votingCards || !modalHelp || !signOutLink) {
    return;
  }

  const modal = document.getElementById("voting-cards-proposal-modal");
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
    if (isChecked() || modal.style.display === "block") {
      return false;
    }
    return true;
  };

  check.addEventListener("change", () => {
    saveState(check.checked);
  });

  modal.querySelector(".vote-action").addEventListener("click", () => {
    modal.dataset.action.click();
    $(modal).foundation("close");
  });

  document.querySelector(".button--vote-button .voting-voting_cards").addEventListener("click", function (evt) {
    if (showModal()) {
      evt.stopPropagation();
      evt.preventDefault();
      check.checked = isChecked();
      modal.dataset.action = evt.currentTarget;
      card.className = evt.currentTarget.className;
      if (evt.currentTarget.children.length > 1) {
        card.innerHTML = `${evt.currentTarget.children[1].outerHTML}<p class="vote-label">${evt.currentTarget.children[1].children[0].textContent}</p>`;
      } else if (card.classList.contains("button")) {
        card.classList.remove("button");
        card.innerHTML = `<p class="vote-label">${evt.currentTarget.title}</p>`;
      } else {
        card.innerHTML = `<p class="vote-label">${evt.currentTarget.textContent}</p>`;
      }
      $(modal).foundation("open");
    } else {
      evt.currentTarget.closest(".voting-voting_cards").classList.add("loading");
    }
  });
});

