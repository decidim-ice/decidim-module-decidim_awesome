// = require form-render.min
// = require decidim/decidim_awesome/forms/rich_text_plugin

class CustomFieldsBuilder { // eslint-disable-line no-unused-vars
  constructor(container_selector) {
    this.container_selector = container_selector || ".proposal_custom_field:last";
    this.lang = this.getLang($("html").attr("lang"));
  }

  getLang(lang) {
    const langs = {
      // ar: 'ar-SA', // Not in decidim yet
      'ar': 'ar-TN',
      'ca': 'ca-ES',
      'cs': 'cs-CZ',
      'da': 'da-DK',
      'de': 'de-DE',
      'el': 'el-GR',
      'en': 'en-US',
      'es': 'es-ES',
      'fa': 'fa-IR',
      'fi': 'fi-FI',
      'fr': 'fr-FR',
      'he': 'he-IL',
      'hu': 'hu-HU',
      'it': 'it-IT',
      'ja': 'ja-JP',
      'my': 'my-MM',
      'nb': 'nb-NO',
      'nl': 'nl-NL',
      'pl': 'pl-PL',
      'pt': 'pt-BR',
      'qz': 'qz-MM',
      'ro': 'ro-RO',
      'ru': 'ru-RU',
      'sl': 'sl-SI',
      'th': 'th-TH',
      'tr': 'tr-TR',
      'uk': 'uk-UA',
      'vi': 'vi-VN',
      'zh-TW': 'zh-TW',
      'zh': 'zh-CN'
    };
    if(langs[lang]) {
      return langs[lang];
    }
    if(langs[lang.substr(0, 2)]) {
      return langs[lang.substr(0, 2)];
    }
    return 'en-US';
  }

  /*
  * Creates an XML document with a subset of html-compatible dl/dd/dt elements
  * to store the custom fields answers
  */
  dataToXML(data) {
    const doc = $.parseXML("<xml/>");
    const xml = doc.getElementsByTagName("xml")[0];
    const dl = doc.createElement("dl");
    let key, dt, dd, div, val, text, label, l;
    xml.appendChild(dl);
    $(dl).attr("class", "decidim_awesome-custom_fields");
    $(dl).attr("data-generator", "decidim_awesome");
    $(dl).attr("data-version", window.DecidimAwesome.version);
    for (key in data) {
      // console.log("get the data!", key, data[key]);
      // Richtext plugin does not saves userdata, so we get it from the hidden input
      if(data[key].type == "textarea" && data[key].subtype == "richtext") {
        data[key].userData = [$(`#${data[key].name}-input`).val()];
      }
      if (data[key].userData && data[key].userData.length) {
        dt = doc.createElement("dt");
        $(dt).text(data[key].label);
        $(dt).attr("name", data[key].name);
        dd = doc.createElement("dd");
        // console.log("data for", key, data[key].name, data[key])
        for(val in data[key].userData) {
          div = doc.createElement("div");
          label = data[key].userData[val];
          text = null;
          if(data[key].values) {
            l = data[key].values.find((v) => v["value"] == data[key].userData[val]);
            if(l) {
              text = label;
              label = l.label;
            }
          } else if(data[key].type == "date" && label) {
            l = new Date(label).toLocaleDateString();
            if(l) {
              text = label;
              label = l;
            }
          }
            // console.log("userData", text, "label", label, 'key', key, 'data', data)
          if(data[key].type == "textarea" && data[key].subtype == "richtext") {
            $(div).html(label);
          } else {
            $(div).text(label);
          }
          if(text) {
            $(div).attr("alt", text);
          }
          dd.appendChild(div);
        }
        $(dd).attr("id", data[key].name);
        $(dd).attr("name", data[key].type);
        dl.appendChild(dt);
        dl.appendChild(dd);
      }
    }
    return xml.outerHTML;
  }

  /**
  * Hack to fix required checkboxes being reset
  * Issue: https://github.com/Platoniq/decidim-module-decidim_awesome/issues/82
  */
  fixBuggyFields() {
    if(!this.$container) {
      return false;
    }
    this.$container.find('.formbuilder-checkbox-group').each((_key, group) => {
      const inputs = $('.formbuilder-checkbox input', group);
      const data = this.spec.find((a) => a.type=="checkbox-group");
      if(!inputs.length || !data || !data.userData) {
        return;
      }
      let values = data.userData;
      
      inputs.each(function (_key, input) {
        let index = values.indexOf(input.value);
        input.checked = (index >= 0);
        if(input.checked) values.splice(index, 1)
      });
      
      // Fill "other" option
      const other_option = $('.other-option', inputs.parent())[0];
      const other_val = $('.other-val', inputs.parent())[0];
      const other_text = values.join(" ");
      
      if (other_option) {
        if (other_text) {
          other_option.checked = true;
          other_option.value = other_text;
          other_val.value = other_text;
        } else {
          other_option.checked = false;
          other_option.value = '';
          other_val.value = '';
        }
      }
    });
  }

  // Saves xml to the hidden input
  storeData() {
    if(!this.$container) {
      return false;
    }
    const $form = this.$container.closest("form");
    const $body = $form.find('input[name="' + this.$element.data("name") +'"]');
    if($body.length && this.instance) {
      this.spec = this.instance.userData;
      $body.val(this.dataToXML(this.spec));
      this.$element.data("spec", this.spec);
    }
    // console.log("storeData", this.spec, "xml", $body.val());
  }

  init($element) {
    this.$element = $element;
    this.spec = $element.data("spec");
    if(!this.$container) {
      this.$container = $(this.container_selector);
    }
    // console.log("init", $element, "data", data)
    // TODO: save current data to the hidden field
    // always use the last field (in case of multilang tabs we only render one form due a limitation of the library to handle several instances)
    this.instance = this.$container.formRender({
      i18n: {
        locale: this.lang,
        location: 'https://cdn.jsdelivr.net/npm/formbuilder-languages@1.1.0/'
      },
      formData: this.spec,
      render: true
    });
    this.fixBuggyFields();
  }
}