// TomSelect plugin: adds move up/down buttons to selected items for reordering.
// Follows the same pattern as TomSelect's built-in "remove_button" plugin.
// Move logic mirrors Decidim's DynamicFieldsComponent (_moveUpField/_moveDownField).

/* eslint-disable require-jsdoc, no-invalid-this, consistent-this */
export default function (userOptions) {
  const self = this;
  if (self.settings.mode !== "multi") {
    return;
  }

  const options = Object.assign({ upTitle: "↑", downTitle: "↓" }, userOptions);

  const syncOrder = () => {
    const values = [];
    self.control.querySelectorAll("[data-value]").forEach((el) => {
      if (el.dataset.value) {
        values.push(el.dataset.value);
      }
    });
    self.setValue(values, true);
  };

  // Bind delegated listeners after TomSelect creates the control element
  self.on("initialize", () => {
    self.control.addEventListener("click", (ev) => {
      const btn = ev.target.closest(".reorder-btn");
      if (!btn) {
        return;
      }
      ev.preventDefault();
      ev.stopPropagation();

      const item = btn.closest("[data-value]");
      if (!item) {
        return;
      }

      if (btn.classList.contains("reorder-up") && item.previousElementSibling?.dataset.value) {
        item.parentNode.insertBefore(item, item.previousElementSibling);
        syncOrder();
      } else if (btn.classList.contains("reorder-down") && item.nextElementSibling?.dataset.value) {
        item.parentNode.insertBefore(item.nextElementSibling, item);
        syncOrder();
      }
    });

    self.control.addEventListener("mousedown", (ev) => {
      if (ev.target.closest(".reorder-btn")) {
        ev.preventDefault();
        ev.stopPropagation();
      }
    }, true);
  });

  // Append reorder buttons to each rendered item
  self.hook("after", "setupTemplates", () => {
    const origRenderItem = self.settings.render.item;

    self.settings.render.item = (data, escape) => {
      const item = Reflect.apply(origRenderItem, self, [data, escape]);
      const el = (typeof item === "string")
        ? new DOMParser().parseFromString(item, "text/html").body.firstChild
        : item;

      const btnUp = document.createElement("button");
      btnUp.type = "button";
      btnUp.className = "reorder-btn reorder-up";
      btnUp.textContent = "↑";
      btnUp.title = options.upTitle;
      btnUp.setAttribute("aria-label", options.upTitle);
      btnUp.tabIndex = 0;

      const btnDown = document.createElement("button");
      btnDown.type = "button";
      btnDown.className = "reorder-btn reorder-down";
      btnDown.textContent = "↓";
      btnDown.title = options.downTitle;
      btnDown.setAttribute("aria-label", options.downTitle);
      btnDown.tabIndex = 0;

      el.insertBefore(btnDown, el.firstChild);
      el.insertBefore(btnUp, el.firstChild);

      return el;
    };
  });
}
