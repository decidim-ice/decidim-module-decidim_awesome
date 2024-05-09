import "formBuilder/dist/form-builder.min.js";
import "src/decidim/decidim_awesome/forms/rich_text_plugin"

window.sortable = () => {}

window.CustomFieldsBuilders = window.CustomFieldsBuilders || [];

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".awesome-edit-config .proposal_custom_fields_editor").forEach(el => {
    const container = el.closest(".proposal_custom_fields_container");
    const key = container.getAttribute("data-key");

    const formData = document.querySelector(`input[name="config[proposal_custom_fields][${key}]"]`).value;

    const customFieldBuilder = {
      el: el,
      key: key,
      config: {
        i18n: {
          locale: "en-US",
          location: "https://cdn.jsdelivr.net/npm/formbuilder-languages@1.1.0/"
        },
        formData: formData,
        disableFields: ["button", "file"],
        disabledActionButtons: ["save", "data", "clear"],
        disabledAttrs: [
          "access",
          "inline",
          "className"
        ],
        controlOrder: [
          "text",
          "textarea",
          "number",
          "date",
          "checkbox-group",
          "radio-group",
          "select",
          "autocomplete",
          "header",
          "paragraph"
        ],
        disabledSubtypes: {
          text: ["color"],
          textarea: ["tinymce", "quill"]
        }
      },
      instance: null
    };

    window.CustomFieldsBuilders.push(customFieldBuilder);
  });

  document.addEventListener("formBuilder.create", (event) => {
    const detail = event.detail;
    const [idx, list] = detail;
    if (!list[idx]) {
      return;
    }

    // Имитация работы formBuilder без jQuery
    const formBuilderResult = { actions: { getData: () => JSON.stringify({ key: list[idx].key }) } };
    list[idx].instance = formBuilderResult;
    list[idx].el.FormBuilder = formBuilderResult;

    const spinner = list[idx].el.querySelector(".loading-spinner");
    if (spinner) {
      spinner.remove();
    }

    const customEvent = new CustomEvent("formBuilder.created", { detail: [list[idx]] });
    document.dispatchEvent(customEvent);

    if (idx < list.length) {
      document.dispatchEvent(new CustomEvent("formBuilder.create", { detail: [idx + 1, list] }));
    }
  });

  if (window.CustomFieldsBuilders.length) {
    document.dispatchEvent(new CustomEvent("formBuilder.create", { detail: [0, window.CustomFieldsBuilders] }));
  }

  document.querySelectorAll("form.awesome-edit-config").forEach(form => {
    form.addEventListener("submit", () => {
      window.CustomFieldsBuilders.forEach(builder => {
        const input = form.querySelector(`input[name="config[proposal_custom_fields][${builder.key}]"]`);
        input.value = builder.instance.actions.getData("json");
      });
    });
  });
});
