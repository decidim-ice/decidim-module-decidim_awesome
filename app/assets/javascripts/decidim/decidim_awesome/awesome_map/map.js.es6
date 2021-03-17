// = require decidim/decidim_awesome/awesome_map/layers
// = require decidim/decidim_awesome/awesome_map/utilities
// = require decidim/decidim_awesome/awesome_map/markers
// = require decidim/decidim_awesome/awesome_map/categories
// = require decidim/decidim_awesome/awesome_map/proposals
// = require decidim/decidim_awesome/awesome_map/meetings
// = require_self

((exports) => {
  const {
    layers,
    cluster,
    control,
    addProposalsControls,
    addMeetingsControls,
    addSearchControls,
    addCategoriesControls,
    addHashtagsControls,
    fetchProposals,
    fetchMeetings,
    options,
    show,
    components,
    amendments,
    allMarkers,
    drawMarker,
    getCategory
  } = exports.AwesomeMap;

  const autoResizeMap = (map) => {
    // Setup center/zoom options if specified, otherwise fitbounds
    if(options.center) {
      map.setView(options.center, options.zoom);
    } else {
      map.fitBounds(cluster.getBounds(), { padding: [50, 50] });
    }
  };

  const loadElements = (map) => {
    // legends
    control.addTo(map);
    cluster.addTo(map);

    // Load markers
    components.forEach((component) => {
      if(component.type == "proposals") {
        addProposalsControls(map, component);

        fetchProposals(component, '', (element, marker) => {
            // console.log(element.state, show[element.state || 'notAnswered'], show, element);
            if(show[element.state || 'notAnswered']) {
              drawMarker(element, marker, component).addTo(layers.proposals.group);
              addHashtagsControls(map, element.hashtags, marker);
            }
          }, () => { // final call
            // Setup center/zoom options if specified, otherwise fitbounds
            autoResizeMap(map);

            allMarkers.forEach((item) => {
              // add marker to amendments layers if it's an amendment
              if(amendments.find((a) => a == item.element.id)) {
                item.marker.removeFrom(layers.proposals.group);
                if(options.menu.amendments) {
                  item.marker.addTo(layers.amendments.group);
                }
              }
            });
          });
        }

        if(options.menu.meetings && component.type == "meetings") {
          addMeetingsControls(map, component);

          fetchMeetings(component, '', (element, marker) => {
            drawMarker(element, marker, component).addTo(layers.meetings.group);
          }, () => autoResizeMap(map) );
        }
      });

    addSearchControls(map);
    addCategoriesControls(map);

    // category events
    $("#awesome-map").on("change", ".awesome_map-categories-selector", (e) => {
      e.preventDefault();
      e.stopPropagation();
      const id = $(e.target).closest("label").data("layer");
      const cat = getCategory(id);
      // console.log("changed, layer", id, "cat", cat, "checked", e.target.checked, e);
      if(cat) {
        const layer = layers[cat.id];
        if(e.target.checked) {
          // show group of markers
          map.addLayer(layer.group);

          // if it's a children, put the parent to indeterminate
          indeterminateInput(cat.parent);
        } else {
          // show group of markers
          map.removeLayer(layer.group);
          // if it's a children, put the parent to indeterminate
          cat.children().forEach((c) => {
            let $el = $(`.awesome_map-category-${c.id}`);
            if($el.parent().prev().prop("checked")) {
              $el.click();
            }
          });
        }
      }
    });

    const indeterminateInput = (id) => {
      $('[class^="awesome_map-category-"]').parent().prev().prop("indeterminate", false);
      if(id) {
        let $input = $(`.awesome_map-category-${id}`).parent().prev();
        if(!$input.prop("checked")) {
          $input.prop("indeterminate", true);
        }
      }
    };

    // hashtag events
    $("#awesome-map").on("change", ".awesome_map-hashtags-selector", (e) => {
      e.preventDefault();
      e.stopPropagation();
      const gid = $(e.target).closest("label").data("layer");
      // console.log("changed, layer", gid, "checked", e.target.checked, e);
      if(gid) {
        const layer = layers[gid];
        if(e.target.checked) {
          // show group of markers
          map.addLayer(layer.group);
        } else {
          // show group of markers
          map.removeLayer(layer.group);
        }
      }
    });
    // sub-layer hashtag title toggle
    $("#awesome-map").on("click", ".awesome_map-title-control", (e) => {
      $(e.target).parent().toggleClass("active");
    });
  };

  $("#map").on("ready.decidim", (_e, map) => {
    if(options.center) {
      map.setView(options.center, options.zoom);
    }
    loadElements(map);
  });

})(window);
