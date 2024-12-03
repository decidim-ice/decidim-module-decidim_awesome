document.addEventListener("DOMContentLoaded", () => {
  const dialog = document.getElementById("awesome-verification-modal");
  if (!dialog) {
    return;
  }
  const container = dialog.querySelector("[data-dialog-container]");
  
  dialog.addEventListener("open.dialog", async (el) => {
    const modal = window.Decidim.currentDialogs[el.target.id];
    const button = modal.openingTrigger;
    const url = button.dataset.verificationUrl;
    container.innerHTML = '<br><br><span class="loading-spinner"></span>';
    // console.log("open.dialog", el, "container", container, "button", button, "url", url);
    fetch(url).then((res) => res.text()).then((html) => {
      container.innerHTML = html;
    });
  });
  
  
  document.body.addEventListener("ajax:complete", (responseText) => {
    const response = JSON.parse(responseText.detail[0].response)
    const button = document.querySelector(`[data-verification-handler="${response.handler}"][data-verification-user-id="${response.userId}"]`);
    // console.log("ajax:complete", responseText, "response", response, "button", button);
    container.innerHTML = response.message;

    if (response.granted) {
      button.classList.add("granted");
    } else {
      button.classList.remove("granted");
      const forceVerificationCheck = container.querySelector("#force_verification_check");
      const forceVerification = container.querySelector("#force_verification");
    
      if (forceVerificationCheck) {
        forceVerificationCheck.addEventListener("change", function() {
          forceVerification.disabled = !forceVerification.disabled;
          if (forceVerificationCheck.checked) {
            forceVerification.focus()
          }
        });
      }
    }
  });
});
