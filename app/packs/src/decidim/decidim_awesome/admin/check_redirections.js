document.addEventListener("DOMContentLoaded", () => {
  const checkCustomRedirections = document.querySelector(".check-custom-redirections");

  if (checkCustomRedirections) {
    checkCustomRedirections.addEventListener("click", (evt) => {
      evt.preventDefault();

      if (evt.target.classList.contains("disabled")) {
        return;
      }

      evt.target.classList.add("disabled");

      const getReport = (tr, response) => {
        const item = JSON.parse(tr.dataset.item);
        const td = tr.querySelector(".redirect-status");

        let type = response.type;
        let status = response.status;
        if (response.type === "opaqueredirect") {
          type = "redirect";
          status = "302";
        }

        if (item.active) {
          if (type === "redirect") {
            td.classList.add("text-success");
          } else {
            td.classList.add("text-alert");
          }
        } else {
          td.classList.add("text-gray");
        }

        return `${type} (${status})`;
      };

      document.querySelectorAll("tr.custom-redirection").forEach((tr) => {
        const td = tr.querySelector(".redirect-status");
        td.innerHTML = '<span class="loading-spinner"></span>';

        fetch(tr.dataset.origin, { method: "HEAD", redirect: "manual" }).
          then((response) => {
            td.innerHTML = getReport(tr, response);
          }).
          catch((error) => {
            console.error("ERROR", error);
            td.classList.remove("loading");
          });
      });
    });
  }
});
