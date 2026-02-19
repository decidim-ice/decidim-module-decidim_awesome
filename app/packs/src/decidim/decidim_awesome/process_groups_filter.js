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

  // Remove tag via event delegation
  if (tagsContainer) {
    tagsContainer.addEventListener("click", (event) => {
      const removeBtn = event.target.closest("[data-remove-tag]");
      if (!removeBtn) {
        return;
      }
      const targetId = removeBtn.dataset.removeTag;
      checkboxes.forEach((checkbox) => {
        if (checkbox.value === targetId) {
          checkbox.checked = false;
          checkbox.dispatchEvent(new Event("change"));
        }
      });
    });
  }
});
