document.addEventListener("DOMContentLoaded", () => {
  const notifyUsersSection = document.querySelector("[data-notify-users]");
  const justificationMessageSection = document.querySelector("[data-justification-message]");
  const configNotifyUsersCheckBox = document.getElementById("users_autoblocks_config_notify_blocked_users");

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

  configNotifyUsersCheckBox.addEventListener("change", () => {
    reviewJustificationMessageSection();
  });
});
