/* eslint no-use-before-define: "off" */

// This script manually handles the "edit" button from the constraints editor by loading the content into the modal after the modal (operated by Dialog) is opened.
// We don't use the RemoteModal class because it chaches the modal content and the "fetch" operation does not specify the "no-cache" headers.

const fetchConstraints = (url, callback = () => {}) => {
  fetch(url, { cache: "no-cache" }).
    then((res) => {
      if (!res.ok) {
        throw res;
      }
      return res.text();
    }).
    then((text) => {
      callback(text);
    }).
    catch((err) => {
      console.error("dialog open failed", err);
    });
};

const renderModal = (element, html) => {
  element.innerHTML = html;
  bindModalEvents(element)
};

const constraintChange = (modalId, data) => {
  const modal = window.Decidim.currentDialogs[modalId];
  const constraintsUrl = modal.openingTrigger.dataset.constraintsUrl;

  // Prepare parameters to request the modal content again, but updated based on the user selections
  const vars = data.map((setting) => `${setting.key}=${setting.value}`);
  const url = `${constraintsUrl}&${vars.join("&")}`;

  fetchConstraints(url, (res) => renderModal(modal.dialog, res));
};

const bindModalEvents = (detail) => {
  const div = detail.querySelector("[id^=constraint-form");
  const spaceManifest = div.getElementsByTagName("select")[0];
  const spaceSlug = div.getElementsByTagName("select")[1];
  const componentManifest = div.getElementsByTagName("select")[2];
  const componentId = div.getElementsByTagName("select")[3];

  spaceManifest.addEventListener("change", (event) => {
    constraintChange(detail.id, [{
      key: "participatory_space_manifest",
      value: event.target.value
    }])
  });

  spaceSlug.addEventListener("change", (event) => {
    constraintChange(detail.id, [{
      key: "participatory_space_manifest",
      value: spaceManifest.value
    }, {
      key: "participatory_space_slug",
      value: event.target.value
    }])
  });

  // Component manfiest and component id are mutually exclusive
  componentManifest.addEventListener("change", (event) => {
    if (event.target.value) {
      componentId.value = "";
    }
  });

  componentId.addEventListener("change", (event) => {
    if (event.target.value) {
      componentManifest.value = "";
    }
  });
};


const initializeDialog = (dialog) => {
  dialog.addEventListener("open.dialog", async (el) => {
    const dialog = window.Decidim.currentDialogs[el.target.id];
    const button = dialog && dialog.openingTrigger;
    const url = button.dataset.constraintsUrl;
    // console.log("open.dialog", el, url, "dialog",dialog);
    fetchConstraints(url, (res) => renderModal(el.target, res));
  });
};

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("[data-dialog]").forEach((dialog) => {
    initializeDialog(dialog);
  });
});

document.addEventListener("ajax:loaded:modals", (event) => {
  event.detail.forEach((modal) => initializeDialog(modal));
});

// Rails AJAX events, this will update the parent page constrains
document.body.addEventListener("ajax:error", (responseText) => {
  // console.log("ajax:error", responseText)
  const container = document.querySelector(`.constraints-editor[data-key="${responseText.detail[0].key}"]`);
  const callout = container.querySelector(".flash");
  callout.hidden = false;
  callout.classList.add("alert");
  callout.getElementsByTagName("p")[0].innerHTML = `${responseText.detail[0].message}: <strong>${responseText.detail[0].error}</strong>`;
});

document.body.addEventListener("ajax:success", (responseText) => {
  // console.log("ajax:success", responseText)
  let container = document.querySelector(`.constraints-editor[data-key="${responseText.detail[0].key}"]`);
  const callout = container.querySelector(".flash");
  callout.hidden = false;
  callout.classList.add("success");
  callout.getElementsByTagName("p")[0].innerHTML = responseText.detail[0].message;
  container.outerHTML = responseText.detail[0].html;
});
