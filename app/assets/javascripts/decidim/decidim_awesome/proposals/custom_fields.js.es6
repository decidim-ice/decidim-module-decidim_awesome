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
    let key, dt, dd, ul, li, val;
    xml.appendChild(dl);
    $(dl).attr("class", "decidim_awesome-custom_fields");
    $(dl).attr("data-generator", "decidim_awesome");
    $(dl).attr("data-version", DecidimAwesome.version);
    for (key in data) {
      if (data.hasOwnProperty(key) && data[key].userData && data[key].userData.length) {
        dt = doc.createElement("dt");
        dd = doc.createElement("dd");
        $(dt).attr("name", data[key].name);
        $(dt).text(data[key].label);
        ul = doc.createElement("ul")
        for(val in data[key].userData) {
          li = doc.createElement("li");
          $(li).text(data[key].userData[val]);
          ul.appendChild(li);
        }
        dd.appendChild(ul);
        $(dd).attr("name", data[key].name);
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
      formData: data
    };

    const $render = $(element).formRender(formRenderOps);
    $form.on("submit", (e) => {
      $body.val(dataToXML($render.userData));
    });
  });
});
