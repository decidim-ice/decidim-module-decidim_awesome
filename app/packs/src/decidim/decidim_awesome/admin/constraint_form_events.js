document.addEventListener("remote-modal:loaded", ({ detail }) => {
  let div = detail.querySelector("[id^=constraint-form");
  let spaceManifest = div.getElementsByTagName("select")[0];
  let spaceSlug = div.getElementsByTagName("select")[1];
  let componentManifest = div.getElementsByTagName("select")[2];
  let componentId = div.getElementsByTagName("select")[3];

  spaceManifest.addEventListener("change", function(event) {
    let customEvent = new CustomEvent("constraint:change", {
      detail: [{
        key: "participatory_space_manifest",
        value: event.target.value,
        modalId: detail.parentElement.id
      }]
    });

    // Dispatch detail as event so main processor will reload accordingly
    document.body.dispatchEvent(customEvent);
  });

  spaceSlug.addEventListener("change", function(event) {
    let customEvent = new CustomEvent("constraint:change", {
      detail: [{
        key: "participatory_space_manifest",
        value: spaceManifest.value,
        modalId: detail.parentElement.id
      }, {
        key: "participatory_space_slug",
        value: event.target.value,
        modalId: detail.parentElement.id
      }]
    });

    // Dispatch detail as event so main processor will reload accordingly
    document.body.dispatchEvent(customEvent);
  });

  // Component manfiest and component id are mutually exclusive
  componentManifest.addEventListener("change", function(event) {
    if (event.target.value)
    {componentId.value = "";}
  });

  componentId.addEventListener("change", function(event) {
    if (event.target.value)
    {componentManifest.value = "";}
  });
});
