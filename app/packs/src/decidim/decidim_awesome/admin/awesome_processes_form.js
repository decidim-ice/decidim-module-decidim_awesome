import TomSelect from "tom-select/dist/cjs/tom-select.popular";
import reorderPlugin from "src/decidim/decidim_awesome/admin/tom_select_reorder";

TomSelect.define("reorder_buttons", reorderPlugin);

document.addEventListener("turbo:load", () => {
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
  if (!multiSelect) {
    return;
  }

  // Read data attributes from <option> elements before TomSelect replaces them
  const optionMeta = {};
  multiSelect.querySelectorAll("option").forEach((opt) => {
    if (opt.value) {
      optionMeta[opt.value] = {
        groupId: parseInt(opt.dataset.groupId || "0", 10),
        status: opt.dataset.status || ""
      };
    }
  });

  /* eslint-disable camelcase */
  const plugins = {
    remove_button: {},
    reorder_buttons: {
      upTitle: manualContainer.dataset.moveUpTitle || "↑",
      downTitle: manualContainer.dataset.moveDownTitle || "↓"
    }
  };
  /* eslint-enable camelcase */
  const tomSelect = new TomSelect(multiSelect, { plugins, create: false });

  const allOptions = Object.values(tomSelect.options).map((opt) => ({ ...opt }));

  const typeSelect = document.querySelector("[data-awesome-processes-type] select");
  const groupSelect = document.querySelector("[name*='process_group_id']");
  const statusSelect = document.querySelector("[name*='process_status']");

  const filterOptions = () => {
    const processType = typeSelect
      ? typeSelect.value
      : "all";
    const groupId = groupSelect
      ? parseInt(groupSelect.value, 10)
      : 0;
    const status = statusSelect
      ? statusSelect.value
      : "active";
    const selectedValues = tomSelect.getValue();

    tomSelect.clearOptions();

    allOptions.forEach((opt) => {
      const meta = optionMeta[opt.value];
      if (!meta) {
        tomSelect.addOption(opt);
        return;
      }

      // Type filter: "processes" = without group, "groups" = with group, "all" = both
      if (processType === "processes" && meta.groupId > 0) {
        return;
      }
      if (processType === "groups" && meta.groupId === 0) {
        return;
      }

      // Group restriction: for "all" type, ungrouped processes always pass
      if (groupId > 0 && meta.groupId !== groupId && !(processType === "all" && meta.groupId === 0)) {
        return;
      }

      // Status filter
      if (status !== "all" && meta.status !== status) {
        return;
      }

      tomSelect.addOption(opt);
    });

    // Preserve already-selected items even if they no longer match filters
    if (Array.isArray(selectedValues)) {
      selectedValues.forEach((val) => {
        if (!tomSelect.options[val]) {
          const original = allOptions.find((op) => op.value === val);
          if (original) {
            tomSelect.addOption(original);
          }
        }
        if (tomSelect.options[val]) {
          tomSelect.addItem(val, true);
        }
      });
    }

    tomSelect.refreshOptions(false);
  };

  if (typeSelect) {
    typeSelect.addEventListener("change", filterOptions);
  }
  if (groupSelect) {
    groupSelect.addEventListener("change", filterOptions);
  }
  if (statusSelect) {
    statusSelect.addEventListener("change", filterOptions);
  }

  filterOptions();

  const toggleCriteriaVisibility = () => {
    manualContainer.hidden = criteriaSelect.value !== "manual";
  };

  criteriaSelect.addEventListener("change", toggleCriteriaVisibility);

  // Toggle group filter visibility: hidden when type = "processes" (ungrouped only)
  const groupFilterContainer = document.querySelector("[data-awesome-processes-group-filter]");
  const mixedHint = document.querySelector("[data-awesome-processes-mixed-hint]");

  if (typeSelect) {
    const toggleTypeDependent = () => {
      if (groupFilterContainer) {
        groupFilterContainer.hidden = typeSelect.value === "processes";
        if (typeSelect.value === "processes" && groupSelect) {
          groupSelect.value = "0";
        }
      }
      if (mixedHint) {
        mixedHint.hidden = typeSelect.value !== "all";
      }
    };

    typeSelect.addEventListener("change", toggleTypeDependent);
  }
});
