// = require decidim/decidim_awesome/editors/quill_editor
// = require decidim/decidim_awesome/form_builder/rich_text_plugin
// = require form-render.min
// = require_self

$(() => {
   /*
   * Creates an XML document with a subset of html-compatible dl/dd/dt elements
   * to store the custom fields answers
   */
  const dataToXML = (data) => {
    const doc = $.parseXML("<xml/>");
    const xml = doc.getElementsByTagName("xml")[0];
    const dl = doc.createElement("dl");
    let key, dt, dd, div, val, text, label, l;
    xml.appendChild(dl);
    $(dl).attr("class", "decidim_awesome-custom_fields");
    $(dl).attr("data-generator", "decidim_awesome");
    $(dl).attr("data-version", window.DecidimAwesome.version);
    for (key in data) {
      // Richtext plugin does not saves userdata, so we get it from the hidden input
      if(data[key].type == "textarea" && data[key].subtype == "richtext") {
        data[key].userData = [$(`#${data[key].name}-input`).val()];
        console.log("get the data!", data[key]);
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
            if(l = data[key].values.find((v) => v["value"] == data[key].userData[val])) {
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
          console.log("userData", text, "label", label, 'key', key, 'data', data)
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
  };

  $(".proposal_custom_field").each((_idx, element) => {
    const data = $(element).data("spec");
    const $form = $(element).closest("form");
    const name = $(element).data("name");
    // console.log(name, data);
    const $body = $form.find('input[name="' + name +'"]');
    const formRenderOps = {
      i18n: {
        locale: 'en-US',
        location: 'https://cdn.jsdelivr.net/npm/formbuilder-languages@1.1.0/'
      },
      formData: data,
      render: true
    };

    const fr = $(element).formRender(formRenderOps);
    // Attach to DOM
    element.FormRender = fr;
    // for external use
    $(document).trigger("formRender.created", [fr]);

   /*
     Hack to fix required checkboxes being reset
     Issue: https://github.com/Platoniq/decidim-module-decidim_awesome/issues/82#issuecomment-862535250
     The problem probably exists somewhere around here:
     Source: https://github.com/kevinchappell/formBuilder/blob/902206505760b8af8417f479a4ddcdc641c46b10/src/js/control/select.js#L36
    */
    $('.formbuilder-checkbox-group').each(function (_key, group) {
      const inputs = $('.formbuilder-checkbox input', group);
      var values = inputs.attr('user-data').split(' ');

      inputs.each(function (_key, input) {
        var index = values.indexOf(input.value);
        if (index >= 0) {
          input.checked = true;
          delete values[index];
        } else {
          input.checked = false;
        }
      });

      // Fill "other" option
      const other_option = $('.other-option', inputs.parent())[0]
      const other_val = $('.other-val', inputs.parent())[0]
      const other_text = values.filter(Boolean)[0]

      if (other_option) {
        if (other_text) {
          other_option.checked = true;
          other_val.value = other_text;
        } else {
          other_option.checked = false;
          other_val.value = '';
        }
      }
    });
    
    $form.on("submit", (e) => {
      console.log("submit!", "fr",fr, "userData", fr.userData);

      if(e.target.checkValidity()) {
        $body.val(dataToXML(fr.userData));
      } else {
        e.preventDefault();
        e.target.reportValidity();
      }
    });
  });
});
