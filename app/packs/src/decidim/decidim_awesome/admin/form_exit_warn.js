document.addEventListener("DOMContentLoaded", () => {
  const form = document.querySelector("form.awesome-edit-config");
  if (form) {
    form.querySelectorAll("input, textarea, select").forEach((el) => {
      el.addEventListener("change", () => {
        form.dataset.changed = true;
      });
    });

    const safePath = form.dataset.safePath.split("?")[0];
    document.querySelectorAll("a").forEach((el) => {
      el.addEventListener("click", () => {
        window.exitUrl = el.href;
      });
    });
    document.querySelectorAll("form").forEach((el) => {
      el.addEventListener("submit", () => {
        window.exitUrl = el.action;
      });
    });
    document.querySelectorAll('[type="submit"]').forEach((el) => {
      el.addEventListener("click", () => {
        window.exitUrl = el.form.action;
      });
    });

    window.addEventListener("beforeunload", (event) => {
      const exitUrl = window.exitUrl;
      const hasChanged = form.dataset.changed;
      window.exitUrl = null;

      if (!hasChanged || (exitUrl && exitUrl.includes(safePath))) {
        return null;
      }

      event.returnValue = true;
      return true;
    });
  }
});
