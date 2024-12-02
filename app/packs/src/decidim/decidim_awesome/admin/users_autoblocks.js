document.addEventListener("DOMContentLoaded", () => {
  const configCheckBox = document.getElementById("users_autoblocks_config_perform_block");

  document.querySelector("[data-justification-message] input").required = false;

  configCheckBox.addEventListener("change", (event) => {
    const form = event.currentTarget.form;
    const submitButton = form.querySelector("[data-perform-block-message]");
    const messages = JSON.parse(submitButton.dataset.performBlockMessage);
    const justificationMessage = form.querySelector("[data-justification-message]");

    if (event.target.checked) {
      submitButton.setAttribute("data-confirm", submitButton.dataset.confirmMessage);
      justificationMessage.classList.remove("hidden");
      justificationMessage.querySelector("input").required = true;
    } else {
      submitButton.removeAttribute("data-confirm");
      justificationMessage.classList.add("hidden");
      justificationMessage.querySelector("input").required = false;
    }
  });
});
