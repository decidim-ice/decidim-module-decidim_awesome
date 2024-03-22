document.addEventListener("DOMContentLoaded", () => {
  const votingCards = document.querySelector(".voting-voting_cards");
  const modal = document.getElementById("voting-cards-modal-help");
  const signOutLink = document.querySelector(".sign-out-link");

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
    console.log("showModal", isChecked(), modal.style.display);
    if (isChecked() || modal.style.display === "block") {
      return false;
    }
    return true;
  };

  check.addEventListener("change", () => {
    saveState(check.checked);
  });

  modal.querySelector(".vote-action").addEventListener("click", () => {
    modal.action.click();
    window.Decidim.currentDialogs[id].close();
  });

  $(".voting-voting_cards").on("click", ".vote-action", (evt) => {
    if (showModal()) {
      evt.stopPropagation();
      evt.preventDefault();
      check.checked = isChecked();
      modal.action = evt.currentTarget;
      card.classList = evt.currentTarget.classList;
      console.log("clicked", evt.currentTarget.children.length, evt.currentTarget.children[1].outerHTML, evt.currentTarget.children[1].children[0].textContent, evt.currentTarget.title, evt.currentTarget.textContent);
      if (evt.currentTarget.children.length > 1) {
        card.innerHTML = `${evt.currentTarget.children[1].outerHTML}<p class="vote-label">${evt.currentTarget.children[1].children[0].textContent}</p>`;
      } else if (card.classList.contains("button")) {
        card.classList.remove("button");
        card.innerHTML = `<p class="vote-label">${evt.currentTarget.title}</p>`;
      } else {
        card.innerHTML = `<p class="vote-label">${evt.currentTarget.textContent}</p>`;
      }
      window.Decidim.currentDialogs[id].open();
    } else {
      evt.currentTarget.closest(".voting-voting_cards").classList.add("loading");
    }
  });
});

