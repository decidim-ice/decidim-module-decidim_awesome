document.addEventListener("remote-modal:loaded", ({ detail }) => {
  var div = detail.querySelector('[id^=constraint-form');
  var space_manifest = div.getElementsByTagName("select")[0];
  var space_slug = div.getElementsByTagName("select")[1];
  var component_manifest = div.getElementsByTagName("select")[2];
  var component_id = div.getElementsByTagName("select")[3];

  space_manifest.addEventListener('change', function(e) {
    var event = new CustomEvent("constraint:change", {
      detail: [{
        key: "participatory_space_manifest",
        value: e.target.value,
        modalId: detail.parentElement.id
      }]
    });

    // Dispatch detail as event so main processor will reload accordingly
    document.body.dispatchEvent(event);
  });

  space_slug.addEventListener('change', function(e) {
    var event = new CustomEvent("constraint:change", {
      detail: [{
        key: "participatory_space_manifest",
        value: space_manifest.value,
        modalId: detail.parentElement.id
      },{
        key: "participatory_space_slug",
        value: e.target.value,
        modalId: detail.parentElement.id
      }]
    });

    // Dispatch detail as event so main processor will reload accordingly
    document.body.dispatchEvent(event);
  });

  // Component manfiest and component id are mutually exclusive
  component_manifest.addEventListener('change', function(e) {
    if(e.target.value)
      component_id.value = "";
  });

  component_id.addEventListener('change', function(e) {
    if(e.target.value)
      component_manifest.value = "";
  });
});
