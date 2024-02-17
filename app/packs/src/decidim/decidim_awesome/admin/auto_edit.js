document.addEventListener("DOMContentLoaded", () => {
  let CustomFieldsBuilders = window.CustomFieldsBuilders || [];

  document.querySelectorAll("a.awesome-auto-edit").forEach((link) => {
    link.addEventListener("click", (ev) => {
      ev.preventDefault();
      const scope = link.dataset.scope;
      const target = document.querySelector(`span.awesome-auto-edit[data-scope="${scope}"]`);
      const constraints = document.querySelector(`.constraints-editor[data-key="${scope}"]`);

      if (!target) {
        return;
      }

      const key = target.dataset.key;
      const attribute = target.dataset.var;
      const hidden = document.querySelector(`[name="config[${attribute}][${key}]"]`);
      const multiple = document.querySelector(`[name="config[${attribute}][${key}][]"]`);
      const container = document.querySelector(`.${attribute}_container[data-key="${key}"]`);
      const deleteBox = container.querySelector("#delete-box");

      const rebuildLabel = (text, withScope) => {
        target.innerText = text;
        target.dataset.key = text;
        if (withScope) {
          target.dataset.scope = withScope;
          link.dataset.scope = withScope;
        }
        link.style.display = "";
      };

      const rebuildHtml = (result) => {
        rebuildLabel(result.key, result.scope);
        constraints.outerHTML = result.html;
        hidden.setAttribute("name", `config[${attribute}][${result.key}]`);
        if (multiple) {
          multiple.setAttribute("name", `config[${attribute}][${result.key}][]`);
        }
        container.dataset.key = result.key;
        container.setAttribute("data-key", result.key);
        deleteBox.setAttribute("href", deleteBox.getAttribute("href").replace(`key=${key}`, `key=${result.key}`));
        CustomFieldsBuilders.forEach((builder) => {
          if (builder.key === key) {
            builder.key = result.key;
          }
        });
        // Reinitialize Decidim DOM events
        // console.log("Reinitializing Decidim DOM events", "constraints", constraints, "container", container);
        // Remove existing dialogs
        Reflect.deleteProperty(window.Decidim.currentDialogs, `edit-modal-${scope}`);
        Reflect.deleteProperty(window.Decidim.currentDialogs, `new-modal-${scope}`);
        const editModal = document.getElementById(`edit-modal-${result.scope}`);
        const newModal = document.getElementById(`new-modal-${result.scope}`);
        if (container) {
          // reloads dialogs (modals)
          document.dispatchEvent(new CustomEvent("ajax:loaded", { detail: container }));
        }
        // Rebuild the manual handling of remote modals
        document.dispatchEvent(new CustomEvent("ajax:loaded:modals", { detail: [editModal, newModal] }));
      };

      target.innerHTML = `<input class="awesome-auto-edit" data-scope="${scope}" type="text" value="${key}">`;
      const input = target.querySelector(`input.awesome-auto-edit[data-scope="${scope}"]`);
      link.style.display = "none";
      input.focus();
      let config = {};
      config[attribute] = true;
      let token = document.querySelector('meta[name="csrf-token"]');
      input.addEventListener("keypress", (evt) => {
        if (evt.key === "Enter" || evt.keyCode === 13 || evt.keyCode ===  10) {
          if (key === input.value) {
            rebuildLabel(key);
            return;
          }
          // console.log("Saving key", key, "to", input.value, "with scope", scope);
          evt.preventDefault();
          fetch(window.DecidimAwesome.rename_scope_label_path, {
            method: "POST",
            headers: {
              "Accept": "application/json, text/plain, */*",
              "Content-Type": "application/json",
              "X-CSRF-Token": token && token.getAttribute("content")
            },
            body: JSON.stringify({ key: key, scope: scope, attribute: attribute, text: input.value, config: config })
          }).
            then((response) => {
              if (!response.ok) {
                throw response;
              }
              return response.json()
            }).
            then((result) => {
              rebuildHtml(result)
            }).
            catch((err) => {
              console.error("Error saving key", key, "ERR:", err);
              rebuildLabel(key);
            });
        }
      });

      input.addEventListener("blur", () => {
        rebuildLabel(key);
      });
    });
  });
});
