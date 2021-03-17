// = require decidim/decidim_awesome/awesome_map/layers
// = require decidim/decidim_awesome/awesome_map/categories

((exports) => {
  const { getCategory, layers } = exports.AwesomeMap;

  const popupMeetingTemplateId = "marker-meeting-popup";
  const popupProposalTemplateId = "marker-proposal-popup";
  const allMarkers = [];

  const drawMarker = (element, marker, component) => {
    let tmpl = component.type === "proposals" ? popupProposalTemplateId : popupMeetingTemplateId,
        node = document.createElement("div");

    $($.templates(`#${tmpl}`).render(element)).appendTo(node);

    marker.bindPopup(node, {
      maxwidth: 640,
      minWidth: 500,
      keepInView: true,
      className: "map-info"
    }).openPopup();

    allMarkers.push({
      marker: marker,
      component: component,
      element: element
    });

    // Add to category layer
    let cat = getCategory(element.category);
    if(layers[cat.id]) {
      marker.addTo(layers[cat.id].group);
      // show category if hidden
      const $label = $(`.awesome_map-category_${cat.id}`).closest("label");
      const $parent = $(`.awesome_map-category_${cat.parent}`).closest("label");
      $label.show();
      // update number of items
      $label.attr("title", parseInt($label.attr("title") || 0) + 1);
      // show parent if apply
      $parent.show();
      $parent.attr("title", parseInt($parent.attr("title") || 0) + 1);
      // update component stats
      const $component = $(`#awesome_map-component_${component.id}`);
      $component.attr("title", parseInt($component.attr("title") || 0) + 1);
    }

    return marker;
  };

  exports.AwesomeMap.allMarkers = allMarkers;
  exports.AwesomeMap.drawMarker = drawMarker;
})(window);
