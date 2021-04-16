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
          } else if(data[key].type == "date") {
            l = new Date(text).toLocaleDateString();
            if(l) {
              text = label;
              label = l;
            }
          }
          // console.log("userData", text, "label", label)
          $(div).text(label);
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

    $form.on("submit", (e) => {
      // console.log("submit!", fr, $body);

      if(e.target.checkValidity()) {
        $body.val(dataToXML(fr.userData));
      } else {
        e.preventDefault();
        e.target.reportValidity();
      }
    });
  });
});
