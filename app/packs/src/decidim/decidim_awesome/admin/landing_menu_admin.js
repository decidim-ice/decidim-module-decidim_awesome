const DRAWER_ID = "item-form";

const initEditor = (editor) => {
  const drawer = window.Decidim.currentDialogs[DRAWER_ID];
  if (!drawer) {
    return;
  }
  const container = drawer.dialog.querySelector("[data-dialog-container]");

  const setDrawerContent = (html) => {
    container.innerHTML = html;
    window.initFoundation(container);

    const form = container.querySelector("#landing-menu-item-form");
    if (!form) {
      return;
    }

    const preset = container.querySelector("#landing-menu-anchor-preset");
    if (preset) {
      preset.addEventListener("change", () => {
        const option = preset.options[preset.selectedIndex];
        const anchor = preset.value;
        const label = option.dataset.label || "";

        if (!anchor) {
          return;
        }

        const urlInput = form.querySelector("input[name$='[url]']");
        if (urlInput) {
          urlInput.value = `#${anchor}`;
        }

        form.querySelectorAll("input[name*='[name_']").forEach((input) => {
          if (!input.value) {
            input.value = label;
          }
        });
      });
    }

    form.addEventListener("ajax:success", () => {
      drawer.close();
      location.reload();
    });

    form.addEventListener("ajax:error", (event) => {
      if (event.detail && event.detail[2]) {
        setDrawerContent(event.detail[2].responseText);
      }
    });
  };

  editor.querySelectorAll(".js-drawer-editor").forEach((button) => {
    button.addEventListener("click", (event) => {
      event.preventDefault();
      container.innerHTML = '<div class="spinner-container">&nbsp;</div>';
      drawer.open();
      fetch(button.dataset.drawerUrl).
        then((response) => response.text()).
        then((html) => setDrawerContent(html));
    });
  });
};

document.addEventListener("decidim:loaded", () => {
  const editor = document.querySelector(".awesome-landing-menu-editor");
  if (editor) {
    initEditor(editor);
  }
});
