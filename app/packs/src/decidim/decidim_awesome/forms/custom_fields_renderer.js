import "formBuilder/dist/form-render.min.js";
import "src/decidim/decidim_awesome/forms/rich_text_plugin"

export default class CustomFieldsRenderer { // eslint-disable-line no-unused-vars
  constructor() {
    this.lang = this.getLang(window.DecidimAwesome.currentLocale);
  }

  getLang(lang) {
    const langs = {
      // ar: 'ar-SA', // Not in decidim yet
      "ar": "ar-TN",
      "ca": "ca-ES",
      "cs": "cs-CZ",
      "da": "da-DK",
      "de": "de-DE",
      "el": "el-GR",
      "en": "en-US",
      "es": "es-ES",
      "fa": "fa-IR",
      "fi": "fi-FI",
      "fr": "fr-FR",
      "he": "he-IL",
      "hu": "hu-HU",
      "it": "it-IT",
      "ja": "ja-JP",
      "my": "my-MM",
      "nb": "nb-NO",
      "nl": "nl-NL",
      "pl": "pl-PL",
      "pt": "pt-BR",
      "qz": "qz-MM",
      "ro": "ro-RO",
      "ru": "ru-RU",
      "sl": "sl-SI",
      "th": "th-TH",
      "tr": "tr-TR",
      "uk": "uk-UA",
      "vi": "vi-VN",
      "zh-TW": "zh-TW",
      "zh": "zh-CN"
    };
    if (langs[lang]) {
      return langs[lang];
    }
    if (langs[lang.substr(0, 2)]) {
      return langs[lang.substr(0, 2)];
    }
    return "en-US";
  }

  /*
  * Creates an XML document with a subset of html-compatible dl/dd/dt elements
  * to store the custom fields answers
  */
  dataToXML(data) {
    const $dl = $("<dl/>");
    let $dd = null,
        $div = null,
        $dt = null,
        datum = null,
        key = null,
        label = null,
        text = null,
        val = null;
    $dl.attr("class", "decidim_awesome-custom_fields");
    $dl.attr("data-generator", "decidim_awesome");
    $dl.attr("data-version", window.DecidimAwesome.version);
    for (key in data) { // eslint-disable-line guard-for-in
      // console.log("get the data!", key, data[key]);
      // Richtext plugin does not saves userdata, so we get it from the hidden input
      if (data[key].type === "textarea" && data[key].subtype === "richtext") {
        data[key].userData = [$(`#${data[key].name}-input`).val()];
      }
      if (data[key].userData && data[key].userData.length) {
        $dt = $("<dt/>");
        $dt.text(data[key].label);
        $dt.attr("name", data[key].name);
        $dd = $("<dd/>");
        // console.log("data for", key, data[key].name, data[key])
        for (val in data[key].userData) { // eslint-disable-line guard-for-in
          $div = $("<div/>");
          label = data[key].userData[val];
          text = null;
          if (data[key].values) {
            datum = data[key].values.find((obj) => obj.value === label); // eslint-disable-line no-loop-func
            if (datum) { // eslint-disable-line max-depth
              text = label;
              label = datum.label;
            }
          } else if (data[key].type === "date" && label) {
            datum = new Date(label).toLocaleDateString();
            if (datum) { // eslint-disable-line max-depth
              text = label;
              label = datum;
            }
          }
          // console.log("userData", text, "label", label, 'key', key, 'data', data)
          if (data[key].type === "textarea" && data[key].subtype === "richtext") {
            $div.html(label);
          } else {
            $div.text(label);
          }
          if (text) {
            $div.attr("alt", text);
          }
          $dd.append($div);
        }
        $dd.attr("id", data[key].name);
        $dd.attr("name", data[key].type);
        $dl.append($dt);
        $dl.append($dd);
      }
    }
    // console.log("dataToXML", $dl[0].outerHTML);
    return `<xml>${$dl[0].outerHTML}</xml>`;
  }

  storeData() {
    if (!this.$element) {
      return false;
    }
    const $form = this.$element.closest("form");
    const $body = $form.find(`input[name="${this.$element.data("name")}"]`);
    if ($body.length && this.instance) {
      this.spec = this.instance.userData;

      this.fixUserDataValues();

      $body.val(this.dataToXML(this.spec));
      this.$element.data("spec", this.spec);
    }
    return this;
  }

  fixUserDataValues() {
    if (!this.spec || !this.$element) {
      return;
    }

    this.spec.forEach((field) => {
      if (!field.userData || field.userData.length === 0) {
        return;
      }

      const hasOnValues = field.userData.some(value => value === "on");
      if (!hasOnValues) {
        return;
      }

      if (field.type === "checkbox-group") {
        const selectors = [
          `input[type="checkbox"][name="${field.name}[]"]:checked`,
          `input[type="checkbox"][name="${field.name}"]:checked`,
          `input[name="${field.name}[]"]:checked`,
          `input[name="${field.name}"]:checked`
        ];

        let $checkboxes = $();
        selectors.forEach(selector => {
          const found = this.$element.find(selector);
          if (found.length > 0) {
            $checkboxes = found;
          }
        });

        const checkedValues = [];
        $checkboxes.each(function() {
          const $checkbox = $(this);
          let value = $checkbox.val();

          if (!value || value === "on") {
            const labelText = $checkbox.closest('label').text().trim() ||
              $checkbox.siblings('label').text().trim() ||
              $checkbox.parent().text().trim();

            if (field.values && field.values.length > 0) {
              const matchingOption = field.values.find(option =>
                option.label === labelText ||
                labelText.includes(option.label) ||
                option.label.includes(labelText)
              );

              if (matchingOption) {
                value = matchingOption.value || matchingOption.label || `option-${field.values.indexOf(matchingOption) + 1}`;
              } else {
                value = labelText || `checkbox-${checkedValues.length + 1}`;
              }
            } else {
              value = labelText || `checkbox-${checkedValues.length + 1}`;
            }
          }

          if (value && value !== "on") {
            checkedValues.push(value);
          }
        });

        if (checkedValues.length > 0) {
          field.userData = checkedValues;
        }
      }

      else if (field.type === "radio-group") {
        const $checkedRadio = this.$element.find(`input[type="radio"][name="${field.name}"]:checked`);

        if ($checkedRadio.length > 0) {
          let value = $checkedRadio.val();

          if (!value || value === "on") {
            const labelText = $checkedRadio.closest('label').text().trim() ||
              $checkedRadio.siblings('label').text().trim();

            if (field.values && field.values.length > 0) {
              const matchingOption = field.values.find(option =>
                option.label === labelText ||
                labelText.includes(option.label)
              );
              value = matchingOption ? (matchingOption.value || matchingOption.label) : labelText;
            } else {
              value = labelText || "radio-selected";
            }
          }

          if (value && value !== "on") {
            field.userData = [value];
          }
        }
      }

      else if (field.type === "select") {
        const $select = this.$element.find(`select[name="${field.name}"]`);

        if ($select.length > 0) {
          let selectedValue = $select.val();

          if (!selectedValue || selectedValue === "on") {
            const selectedText = $select.find('option:selected').text().trim();
            selectedValue = selectedText || "select-option";
          }

          if (selectedValue && selectedValue !== "on") {
            field.userData = [selectedValue];
          }
        }
      }
    });
  }

  fixBuggyFields() {
    if (!this.$element) {
      return false;
    }

    /**
    * Hack to fix required checkboxes being reset
    * Issue: https://github.com/decidim-ice/decidim-module-decidim_awesome/issues/82
    */
    this.$element.find(".formbuilder-checkbox-group").each((_key, group) => {
      const inputs = $(".formbuilder-checkbox input", group);
      const $label = $(group).find("label");
      const data = this.spec.find((obj) => obj.type === "checkbox-group" && obj.name === $label.attr("for"));
      let values = data?.userData;
      if (!inputs.length || !data || !values) {
        return;
      }

      inputs.each((_idx, input) => {
        const $input = $(input);
        let shouldCheck = false;

        let index = values.indexOf(input.value);
        if (index >= 0) {
          shouldCheck = true;
          values.splice(index, 1);
        } else {
          const labelText = $input.closest('label').text().trim() ||
            $input.siblings('label').text().trim() ||
            $input.parent().text().trim();

          if (labelText) {
            const matchIndex = values.findIndex(value =>
              value === labelText ||
              labelText.includes(value) ||
              value.includes(labelText)
            );

            if (matchIndex >= 0) {
              shouldCheck = true;
              values.splice(matchIndex, 1);
            }
          }
        }

        if (shouldCheck) {
          if (!input.checked) {
            $(input).click();
          }
        } else if (input.checked) {
          $(input).click();
        }
      });

      const otherOption = $(".other-option", inputs.parent())[0];
      const otherVal = $(".other-val", inputs.parent())[0];
      const otherText = values.join(" ");

      if (otherOption) {
        if (otherText) {
          otherOption.checked = true;
          otherOption.value = otherText;
          otherVal.value = otherText;
        } else {
          otherOption.checked = false;
          otherOption.value = "";
          otherVal.value = "";
        }
      }
    });

    /**
    * Hack to fix required radio buttons "other" value
    * Issue: https://github.com/decidim-ice/decidim-module-decidim_awesome/issues/133
    */
    this.$element.find(".formbuilder-radio input.other-val").on("input", (input) => {
      const $input = $(input.currentTarget);
      const $group = $input.closest(".formbuilder-radio-group");
      $group.find("input").each((_key, radio) => {
        const name = $(radio).attr("name");
        if (name && name.endsWith("[]")) {
          $(radio).attr("name", name.slice(0, -2));
        }
      });
    });

    return this;
  }

  init($element) {
    this.$element = $element;
    this.spec = $element.data("spec");
    // console.log("init", $element, "this", this)
    // in case of multilang tabs we only render one form due a limitation in the library for handling several instances
    this.instance = $element.formRender({
      i18n: {
        locale: this.lang,
        location: window.DecidimAwesome.formBuilderLangsLocation
      },
      formData: this.spec,
      render: true,
      disableInjectedStyle: true,
      controlConfig: {
        "textarea.richtext": {
          editorOptions: $element.data("editorOptions")
        }
      }
    });
    this.fixBuggyFields();
  }
}
