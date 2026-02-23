// Event delegation on document — no per-element init needed, immune to Turbo cache.

document.addEventListener("change", (event) => {
  if (event.target.type !== "checkbox") {
    return;
  }

  const form = event.target.closest("[data-auto-submit-form]");
  if (form) {
    form.requestSubmit();
  }
});

document.addEventListener("click", (event) => {
  const button = event.target.closest("[data-remove-tag]");
  if (!button) {
    return;
  }

  const container = button.closest("[data-process-groups-filter]");
  if (!container) {
    return;
  }

  const form = container.querySelector("[data-auto-submit-form]");
  if (!form) {
    return;
  }

  const checkbox = form.querySelector(
    `input[name="taxonomy_ids[]"][value="${button.dataset.removeTag}"]`
  );
  if (checkbox) {
    checkbox.checked = false;
  }
  form.requestSubmit();
});
