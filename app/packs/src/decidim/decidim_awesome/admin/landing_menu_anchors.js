document.addEventListener("DOMContentLoaded", () => {
  const anchorsContainer = document.querySelector("[data-landing-menu-anchors]");
  if (!anchorsContainer) return;

  const container = anchorsContainer.closest(".row.column");

  const findActiveTextarea = () =>
    container.querySelector("textarea:not([style*='display: none'])") ||
    container.querySelector("textarea");

  const syncChipStates = () => {
    const textarea = findActiveTextarea();
    if (!textarea) return;

    const text = textarea.value || "";
    anchorsContainer.querySelectorAll("[data-anchor-url]").forEach((chip) => {
      chip.classList.toggle("success", text.includes(chip.dataset.anchorUrl));
    });
  };

  anchorsContainer.addEventListener("click", (event) => {
    const chip = event.target.closest("[data-anchor-label]");
    if (!chip) return;

    const { anchorLabel: label, anchorUrl: url } = chip.dataset;
    const line = `${label} | ${url}`;
    const textarea = findActiveTextarea();
    if (!textarea) return;

    const text = textarea.value.trim();
    const lines = text ? text.split("\n") : [];
    const existingIndex = lines.findIndex((l) => l.includes(url));

    if (existingIndex !== -1) {
      lines.splice(existingIndex, 1);
    } else {
      lines.push(line);
    }

    textarea.value = lines.join("\n");
    textarea.dispatchEvent(new Event("input", { bubbles: true }));
    syncChipStates();
  });

  syncChipStates();
});
