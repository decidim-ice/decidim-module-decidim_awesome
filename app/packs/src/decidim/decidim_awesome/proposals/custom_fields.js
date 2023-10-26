import CustomFieldsRenderer from "src/decidim/decidim_awesome/forms/custom_fields_renderer"

const customFieldsRenderers = window.DecidimAwesome.CustomFieldsRenderer || []

$(() => {
  // use admin multilang specs if exists
  let $customFieldElements = $(".proposal_custom_field", ".tabs-title.is-active");
  if (!$customFieldElements.length) {
    $customFieldElements = $(".proposal_custom_field");
  }
  $customFieldElements.each((index, element) => {
    if(index >= customFieldsRenderers.length) {
      const $element = $(element)
      const renderer = new CustomFieldsRenderer(`#${$element.attr("id")}`)
      customFieldsRenderers.push(renderer);
      renderer.init($element);
      console.log("add", index)
    }
  })

  if(customFieldsRenderers.length > 0){
    customFieldsRenderers[0].$container.closest("form").on("submit", (evt) => {
        if (evt.target.checkValidity()) {
          // save current editor
          customFieldsRenderers.forEach(renderer => {
            renderer.storeData()
          })
        } else {
          evt.preventDefault();
          evt.target.reportValidity();
        }
      });
  }
});


window.DecidimAwesome.CustomFieldsRenderer = customFieldsRenderers;
