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

    const preset = container.querySelector("#landing-menu-anchor-presets");
    if (preset) {
      preset.addEventListener("change", () => {
        const option = preset.options[preset.selectedIndex];
        const url = preset.value;

        if (!url) {
          return;
        }

        const urlInput = form.querySelector("input[name$='[url]']");
        if (urlInput) {
          urlInput.value = url;
        }

        form.querySelectorAll("input[name*='[name_']").forEach((input) => {
          const locale = input.id.substr(input.id.lastIndexOf("_") + 1);
          input.value = option.attributes[`data-label-${locale}`]?.value;
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
