document.addEventListener("DOMContentLoaded", () => {
  const dialog = document.getElementById("awesome-verification-modal");
  const title = dialog.querySelector("[data-dialog-title]");
  const content = dialog.querySelector("[data-dialog-content]");

  dialog.addEventListener("open.dialog", async (el) => {
    const modal = window.Decidim.currentDialogs[el.target.id];
    const button = modal.openingTrigger;
    const url = button.dataset.verificationUrl;
    const user = button.dataset.verificationUser;
    title.innerText = title.innerText.replace("{{user}}", user);
    content.innerHTML = '<br><br><span class="loading-spinner"></span>';
    // console.log("open.dialog", el, "content", content, "button", button, "url", url);
    fetch(url).then((res) => res.text()).then((html) => {
      content.innerHTML = html;
    });
  });
  
  
  document.body.addEventListener("ajax:complete", (responseText) => {
    const response = JSON.parse(responseText.detail[0].response)
    const button = document.querySelector(`[data-verification-handler="${response.handler}"][data-verification-user-id="${response.userId}"]`);
    // console.log("ajax:complete", responseText, "response", response, "button", button);
    content.innerHTML = response.message;

    if (response.granted) {
      button.classList.add("granted");
    } else {
      button.classList.remove("granted");
      const forceVerificationCheck = content.querySelector("#force_verification_check");
      const forceVerification = content.querySelector("#force_verification");
    
      if (forceVerificationCheck) {
        console.log(forceVerificationCheck);
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
