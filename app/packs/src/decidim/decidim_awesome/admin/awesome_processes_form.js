import TomSelect from "tom-select/dist/cjs/tom-select.popular";

document.addEventListener("DOMContentLoaded", () => {
  const criteriaContainer = document.querySelector("[data-awesome-processes-criteria]");
  if (!criteriaContainer) {
    return;
  }

  const criteriaSelect = criteriaContainer.querySelector("select");
  const manualContainer = document.querySelector("[data-awesome-processes-manual]");
  if (!criteriaSelect || !manualContainer) {
    return;
  }

  const multiSelect = manualContainer.querySelector("select.awesome-processes-tom-select");
  if (multiSelect) {
    // eslint-disable-next-line no-new
    new TomSelect(multiSelect, {
      plugins: ["remove_button"],
      create: false
    });
  }

  const toggleCriteriaVisibility = () => {
    manualContainer.hidden = criteriaSelect.value !== "manual";
  };

  criteriaSelect.addEventListener("change", toggleCriteriaVisibility);

  const typeContainer = document.querySelector("[data-awesome-processes-type]");
  const mixedHint = document.querySelector("[data-awesome-processes-mixed-hint]");
  if (typeContainer && mixedHint) {
    const typeSelect = typeContainer.querySelector("select");
    if (typeSelect) {
      const toggleMixedHint = () => {
        mixedHint.hidden = typeSelect.value !== "all";
      };

      typeSelect.addEventListener("change", toggleMixedHint);
    }
  }
});
