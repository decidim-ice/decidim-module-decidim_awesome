import createDynamicFields from "src/decidim/admin/dynamic_fields.component";
import AutoLabelByPositionComponent from "src/decidim/admin/auto_label_by_position.component";

document.addEventListener("turbo:load", () => {
  const wrapper = document.querySelector(".rich-text-columns-wrapper");
  if (!wrapper) {
    return;
  }

  const maxColumns = parseInt(wrapper.dataset.maxColumns, 10) || 6;
  const addButton = wrapper.querySelector(".add-rich-text-column");

  const toggleAddButton = () => {
    const count = wrapper.querySelectorAll(".rich-text-columns-list .rich-text-column:not(.hidden)").length;
    if (addButton) {
      addButton.classList.toggle("hidden", count >= maxColumns);
    }
  };

  const autoLabelByPosition = new AutoLabelByPositionComponent({
    listSelector: ".rich-text-columns-list .rich-text-column:not(.hidden)",
    labelSelector: ".rich-text-column-title",
    onPositionComputed: (el, idx) => {
      const removeButton = el.querySelector(".remove-rich-text-column");
      if (removeButton) {
        removeButton.classList.toggle("hidden", idx === 0);
      }
    }
  });

  createDynamicFields({
    placeholderId: "rich-text-column-id",
    wrapperSelector: ".rich-text-columns-wrapper",
    containerSelector: ".rich-text-columns-list",
    fieldSelector: ".rich-text-column",
    addFieldButtonSelector: ".add-rich-text-column",
    removeFieldButtonSelector: ".remove-rich-text-column",
    onAddField: () => {
      autoLabelByPosition.run();
      toggleAddButton();
    },
    onRemoveField: () => {
      autoLabelByPosition.run();
      toggleAddButton();
    }
  });

  autoLabelByPosition.run();
  toggleAddButton();
});
