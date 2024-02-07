/* eslint func-style: "off", require-jsdoc: "off", no-use-before-define: "off" */

function constraintChange(data) {
  // Identify the modal element to be updated
  const [{ modalId }] = data;
  const modal = window.Decidim.currentDialogs[modalId];
  const { dialogRemoteUrl } = modal.openingTrigger.dataset;

  // Prepare parameters to request the modal content again, but updated based on the user selections
  const vars = data.map((setting) => `${setting.key}=${setting.value}`);
  const url = `${dialogRemoteUrl}&${vars.join("&")}`;

  // Replace only the "-content" markup
  $(modal.dialog.firstElementChild).load(url, (htmlString) => {
    // Update the content of the original modal with the new html
    modal.dialog.firstElementChild.innerHTML = htmlString

    // Pass the same node as the original event "remote-modal:loaded" receives
    // in this way, all js listeners will reboot
    updateModalContent({ detail: modal.dialog.firstElementChild })
  });
}

function updateModalContent({ detail }) {
  let div = detail.querySelector("[id^=constraint-form");
  let spaceManifest = div.getElementsByTagName("select")[0];
  let spaceSlug = div.getElementsByTagName("select")[1];
  let componentManifest = div.getElementsByTagName("select")[2];
  let componentId = div.getElementsByTagName("select")[3];

  spaceManifest.addEventListener("change", function(event) {
    constraintChange([{
      key: "participatory_space_manifest",
      value: event.target.value,
      modalId: detail.parentElement.id
    }])
  });

  spaceSlug.addEventListener("change", function(event) {
    constraintChange([{
      key: "participatory_space_manifest",
      value: spaceManifest.value,
      modalId: detail.parentElement.id
    }, {
      key: "participatory_space_slug",
      value: event.target.value,
      modalId: detail.parentElement.id
    }])
  });

  // Component manfiest and component id are mutually exclusive
  componentManifest.addEventListener("change", function (event) {
    if (event.target.value) {
      componentId.value = "";
    }
  });

  componentId.addEventListener("change", function (event) {
    if (event.target.value) {
      componentManifest.value = "";
    }
  });
}

document.addEventListener("remote-modal:loaded", (event) => updateModalContent(event));
