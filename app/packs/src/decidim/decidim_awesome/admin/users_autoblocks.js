document.addEventListener("DOMContentLoaded", () => {
  const performBlockSection = document.querySelector("[data-perform-block]");
  const notifyUsersSection = document.querySelector("[data-notify-users]");
  const justificationMessageSection = document.querySelector("[data-justification-message]");

  const configPerformBlockCheckBox = document.getElementById("users_autoblocks_config_perform_block");
  const configAllowTaskCheckBox = document.getElementById("users_autoblocks_config_allow_performing_block_from_a_task");
  const configNotifyUsersCheckBox = document.getElementById("users_autoblocks_config_notify_blocked_users");
  const submitButton = document.querySelector("[data-perform-block-message]");

  const reviewJustificationMessageSection = () => {
    if (!notifyUsersSection.classList.contains("hidden") && configNotifyUsersCheckBox.checked) {
      justificationMessageSection.classList.remove("hidden");
      justificationMessageSection.querySelector("input").required = true;
    } else {
      justificationMessageSection.classList.add("hidden");
      justificationMessageSection.querySelector("input").required = false;
    }
  };

  reviewJustificationMessageSection();

  performBlockSection.addEventListener("change", () => {
    if (configPerformBlockCheckBox.checked || configAllowTaskCheckBox.checked) {
      notifyUsersSection.classList.remove("hidden");
    } else {
      notifyUsersSection.classList.add("hidden");
    }
    reviewJustificationMessageSection();
  });

  configPerformBlockCheckBox.addEventListener("change", (event) => {
    const messages = JSON.parse(submitButton.dataset.performBlockMessage);
    submitButton.textContent = messages[event.target.checked];

    if (event.target.checked) {
      submitButton.setAttribute("data-confirm", submitButton.dataset.confirmMessage);
    } else {
      submitButton.removeAttribute("data-confirm");
    }
  });

  configNotifyUsersCheckBox.addEventListener("change", () => {
    reviewJustificationMessageSection();
  });
});
