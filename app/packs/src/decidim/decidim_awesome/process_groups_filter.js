document.addEventListener("turbo:load", () => {
  const container = document.querySelector("[data-process-groups-filter]");
  if (!container) {
    return;
  }

  const tabs = container.querySelectorAll("[data-filter]");
  const checkboxes = container.querySelectorAll("[data-taxonomy-checkbox]");
  const items = container.querySelectorAll("[data-status]");
  const tagsContainer = container.querySelector("[data-active-taxonomy-tags]");

  let currentStatus = "all";

  const getSelectedTaxonomies = () => {
    const selected = [];
    checkboxes.forEach((checkbox) => {
      if (checkbox.checked) {
        selected.push(checkbox.value);
      }
    });
    return selected;
  };

  const updateTags = () => {
    if (!tagsContainer) {
      return;
    }

    tagsContainer.innerHTML = "";
    let hasActive = false;

    checkboxes.forEach((checkbox) => {
      if (!checkbox.checked) {
        return;
      }
      hasActive = true;

      const tag = document.createElement("span");
      tag.className = "label";
      tag.dataset.tagFor = checkbox.value;

      const parentLabel = checkbox.closest("label");
      const name = parentLabel
        ? parentLabel.textContent.trim()
        : checkbox.value;

      tag.innerHTML = `${name} <button type="button" class="pg-tag-remove" data-remove-tag="${checkbox.value}" aria-label="Remove">&times;</button>`;
      tagsContainer.appendChild(tag);
    });

    tagsContainer.hidden = !hasActive;

    tagsContainer.querySelectorAll("[data-remove-tag]").forEach((btn) => {
      btn.addEventListener("click", () => {
        const targetId = btn.dataset.removeTag;
        checkboxes.forEach((checkbox) => {
          if (checkbox.value === targetId) {
            checkbox.checked = false;
            checkbox.dispatchEvent(new Event("change"));
          }
        });
      });
    });
  };

  const applyFilters = () => {
    const selectedTaxonomies = getSelectedTaxonomies();

    items.forEach((item) => {
      const statusMatch = currentStatus === "all" || item.dataset.status === currentStatus;

      let taxonomyMatch = true;
      if (selectedTaxonomies.length > 0) {
        const itemTaxonomies = item.dataset.taxonomyIds
          ? item.dataset.taxonomyIds.split(",")
          : [];
        taxonomyMatch = selectedTaxonomies.some((id) => itemTaxonomies.includes(id));
      }

      item.style.display = statusMatch && taxonomyMatch
        ? ""
        : "none";
    });

    updateTags();
  };

  // Status filter tabs
  tabs.forEach((tab) => {
    tab.addEventListener("click", () => {
      currentStatus = tab.dataset.filter;
      tabs.forEach((tabEl) => tabEl.classList.toggle("is-active", tabEl.dataset.filter === currentStatus));
      applyFilters();
    });
  });

  // Taxonomy checkboxes
  checkboxes.forEach((checkbox) => {
    checkbox.addEventListener("change", applyFilters);
  });

  // Dropdown toggle
  container.querySelectorAll("[data-pg-dropdown]").forEach((trigger) => {
    trigger.addEventListener("click", (event) => {
      event.stopPropagation();
      const panelId = trigger.dataset.pgDropdown;
      const panel = document.getElementById(panelId);
      if (!panel) {
        return;
      }

      const isHidden = panel.hidden;
      // Close all other panels first
      container.querySelectorAll(".pg-filter-dropdown__panel").forEach((panelEl) => {
        panelEl.hidden = true;
        panelEl.previousElementSibling?.setAttribute("aria-expanded", "false");
      });

      panel.hidden = !isHidden;
      trigger.setAttribute(
        "aria-expanded",
        isHidden
          ? "true"
          : "false"
      );
    });
  });

  // Close dropdowns when clicking outside
  document.addEventListener("click", (event) => {
    if (!event.target.closest(".pg-filter-dropdown")) {
      container.querySelectorAll(".pg-filter-dropdown__panel").forEach((panelEl) => {
        panelEl.hidden = true;
      });
      container.querySelectorAll("[data-pg-dropdown]").forEach((triggerEl) => {
        triggerEl.setAttribute("aria-expanded", "false");
      });
    }
  });
});
