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
    let key, dt, dd, div, val;
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
        for(val in data[key].userData) {
          div = doc.createElement("div");
          $(div).text(data[key].userData[val]);
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
    const $body = $form.find("#proposal_body");
    const formRenderOps = {
      i18n: {
        locale: 'en-US',
        location: 'https://cdn.jsdelivr.net/npm/formbuilder-languages@1.1.0/'
      },
      formData: data,
      render: true
    };

    const $render = $(element).formRender(formRenderOps);
    $form.on("submit", (e) => {
      if(e.target.checkValidity()) {
        $body.val(dataToXML($render.userData));
      } else {
        e.preventDefault();
        e.target.reportValidity();
      }
    });
  });
});
