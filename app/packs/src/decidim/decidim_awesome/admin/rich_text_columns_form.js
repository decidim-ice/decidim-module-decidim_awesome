import createDynamicFields from "src/decidim/admin/dynamic_fields.component";
import AutoLabelByPositionComponent from "src/decidim/admin/auto_label_by_position.component";
import { initializeUploadFields } from "src/decidim/direct_uploads/upload_field";

const initColorPickerToggles = (container) => {
  container.querySelectorAll(".awesome-rich-text-transparent-bg").forEach((checkbox) => {
    if (checkbox.dataset.initialized) {
      return;
    }
    checkbox.dataset.initialized = "true";

    const targetId = checkbox.dataset.target;
    const picker = container.querySelector(`#color-picker-${targetId}`);
    if (!picker) {
      return;
    }

    const colorInput = picker.querySelector("input[type='color']");

    const toggle = () => {
      picker.classList.toggle("hidden", checkbox.checked);
      if (colorInput) {
        colorInput.disabled = checkbox.checked;
      }
    };

    toggle();
    checkbox.addEventListener("change", toggle);
  });
};

document.addEventListener("turbo:load", () => {
  const wrapper = document.querySelector(".awesome-rich-text-columns-wrapper");
  if (!wrapper) {
    return;
  }

  const maxColumns = parseInt(wrapper.dataset.maxColumns, 10) || 5;
  const addButton = wrapper.querySelector(".add-awesome-rich-text-column");

  const toggleAddButton = () => {
    const count = wrapper.querySelectorAll(".awesome-rich-text-columns-list .awesome-rich-text-column:not(.hidden)").length;
    if (addButton) {
      addButton.classList.toggle("hidden", count >= maxColumns);
    }
  };

  const autoLabelByPosition = new AutoLabelByPositionComponent({
    listSelector: ".awesome-rich-text-columns-list .awesome-rich-text-column:not(.hidden)",
    labelSelector: ".awesome-rich-text-column-title",
    onPositionComputed: (el, idx) => {
      const removeButton = el.querySelector(".remove-awesome-rich-text-column");
      if (removeButton) {
        removeButton.classList.toggle("hidden", idx === 0);
      }
    }
  });

  createDynamicFields({
    placeholderId: "awesome-rich-text-column-id",
    wrapperSelector: ".awesome-rich-text-columns-wrapper",
    containerSelector: ".awesome-rich-text-columns-list",
    fieldSelector: ".awesome-rich-text-column",
    addFieldButtonSelector: ".add-awesome-rich-text-column",
    removeFieldButtonSelector: ".remove-awesome-rich-text-column",
    onAddField: () => {
      autoLabelByPosition.run();
      toggleAddButton();
      initColorPickerToggles(wrapper);

      const columns = wrapper.querySelectorAll(".awesome-rich-text-columns-list .awesome-rich-text-column");
      const lastColumn = columns[columns.length - 1];
      if (lastColumn) {
        initializeUploadFields(lastColumn.querySelectorAll("button[data-upload]"));
      }
    },
    onRemoveField: () => {
      autoLabelByPosition.run();
      toggleAddButton();
    }
  });

  // Override the default remove behavior: createDynamicFields hides fields
  // instead of removing them when inputs match /id/ in their name attribute.
  // Since our columns are not backed by ActiveRecord, we need actual DOM removal.
  wrapper.addEventListener("click", (event) => {
    const button = event.target.closest(".remove-awesome-rich-text-column");
    if (!button) {
      return;
    }

    event.preventDefault();
    event.stopPropagation();

    const field = button.closest(".awesome-rich-text-column");
    if (field) {
      field.remove();
      autoLabelByPosition.run();
      toggleAddButton();
    }
  }, true);

  autoLabelByPosition.run();
  toggleAddButton();
  initColorPickerToggles(wrapper);
});
