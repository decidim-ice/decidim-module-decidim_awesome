document.addEventListener("DOMContentLoaded", () => {
  const dialog = document.getElementById("awesome-verification-modal");
  dialog.addEventListener("open.dialog", async (el) => {
    const modal = window.Decidim.currentDialogs[el.target.id];
    const button = modal.openingTrigger;
    const handler = button.dataset.verificationHandler;
    const url = button.dataset.verificationUrl;
    const user = button.dataset.verificationUser;
    const title = dialog.querySelector("[data-dialog-title]");
    const content = dialog.querySelector("[data-dialog-content]");
    console.log("open.dialog", el, "url", url, "user", user, "handler", handler, "dialog", dialog);
    title.innerText = title.innerText.replace("{{user}}", user);
    content.innerHTML = '<span class="loading-spinner"></span>';
    fetch(url).then((res) => res.text()).then((html) => {
      console.log("fetch", html);
      content.innerHTML = html;
      // content.querySelector("form").addEventListener("submit", (event) => {
      //   event.preventDefault();
      //   const form = event.target;
      //   const formData = new FormData(form);
      //   const url = form.action;
      //   console.log("submit", event, "form", form, "formData", formData, "url", url);
      //   fetch(url, {
      //     method: "POST",
      //     body: formData,
      //     headers: {
      //       "X-Requested-With": "XMLHttpRequest"
      //     }
      //   }).then((res) => res.json()).then((res) => {
      //     console.log("fetch", res);
      //     if (res.success) {
      //       dialog.close();
      //       window.location.reload();
      //     }
      //   });
      // });
    });
  });
  
});