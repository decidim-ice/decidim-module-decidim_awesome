document.addEventListener("turbo:load", () => {
  const container = document.querySelector("[data-process-groups-filter]");
  if (!container || container.dataset.initialized) {
    return;
  }
  container.dataset.initialized = "true";

  const tabs = container.querySelectorAll("[data-filter]");
  const checkboxes = container.querySelectorAll("[data-taxonomy-checkbox]");
  const items = container.querySelectorAll("[data-status]");
  const tagsContainer = container.querySelector("[data-active-taxonomy-tags]");

  let currentStatus = "all";

  const getSelectedByGroup = () => {
    const groups = {};
    checkboxes.forEach((checkbox) => {
      if (checkbox.checked) {
        const rootId = checkbox.dataset.rootId;
        if (!groups[rootId]) {
          groups[rootId] = [];
        }
        groups[rootId].push(checkbox.value);
      }
    });
    return groups;
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

      tag.appendChild(document.createTextNode(`${name} `));

      const btn = document.createElement("button");
      btn.type = "button";
      btn.className = "pg-tag-remove";
      btn.dataset.removeTag = checkbox.value;
      btn.setAttribute("aria-label", "Remove");
      btn.textContent = "\u00d7";
      tag.appendChild(btn);

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
    const selectedByGroup = getSelectedByGroup();
    const groupKeys = Object.keys(selectedByGroup);

    items.forEach((item) => {
      const statusMatch = currentStatus === "all" || item.dataset.status === currentStatus;

      let taxonomyMatch = true;
      if (groupKeys.length > 0) {
        const itemTaxonomies = item.dataset.taxonomyIds
          ? item.dataset.taxonomyIds.split(",")
          : [];
        // AND between groups, OR within each group
        taxonomyMatch = groupKeys.every((rootId) => {
          return selectedByGroup[rootId].some((id) => itemTaxonomies.includes(id));
        });
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
  const closeDropdowns = (event) => {
    if (!event.target.closest(".pg-filter-dropdown")) {
      container.querySelectorAll(".pg-filter-dropdown__panel").forEach((panelEl) => {
        panelEl.hidden = true;
      });
      container.querySelectorAll("[data-pg-dropdown]").forEach((triggerEl) => {
        triggerEl.setAttribute("aria-expanded", "false");
      });
    }
  };

  document.addEventListener("click", closeDropdowns);

  // Store reference for cleanup
  container._pgCloseDropdowns = closeDropdowns;
});

document.addEventListener("turbo:before-cache", () => {
  const container = document.querySelector("[data-process-groups-filter]");
  if (container) {
    if (container._pgCloseDropdowns) {
      document.removeEventListener("click", container._pgCloseDropdowns);
      container._pgCloseDropdowns = null;
    }
    Reflect.deleteProperty(container.dataset, "initialized");
  }
});
