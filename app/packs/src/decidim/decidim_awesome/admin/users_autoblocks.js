document.addEventListener("DOMContentLoaded", () => {
  const configPerformBlockCheckBox = document.getElementById("users_autoblocks_config_perform_block");
  const configNotifyUsersCheckBox = document.getElementById("users_autoblocks_config_notify_blocked_users");

  document.querySelector("[data-justification-message] input").required = false;

  configPerformBlockCheckBox.addEventListener("change", (event) => {
    const form = event.currentTarget.form;
    const submitButton = form.querySelector("[data-perform-block-message]");
    const messages = JSON.parse(submitButton.dataset.performBlockMessage);
    const notifyUsers = form.querySelector("[data-notify-users]");

    submitButton.textContent = messages[event.target.checked];

    if (event.target.checked) {
      submitButton.setAttribute("data-confirm", submitButton.dataset.confirmMessage);
      notifyUsers.classList.remove("hidden");
    } else {
      submitButton.removeAttribute("data-confirm");
      notifyUsers.classList.add("hidden");
    }
  });

  configNotifyUsersCheckBox.addEventListener("change", (event) => {
    const form = event.currentTarget.form;
    const justificationMessage = form.querySelector("[data-justification-message]");

    if (event.target.checked) {
      justificationMessage.classList.remove("hidden");
      justificationMessage.querySelector("input").required = true;
    } else {
      justificationMessage.classList.add("hidden");
      justificationMessage.querySelector("input").required = false;
    }
  });
});
