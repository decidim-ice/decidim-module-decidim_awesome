// = require jsrender.min
// = require leaflet.featuregroup.subgroup
// = require decidim/decidim_awesome/awesome_map/layers
// = require decidim/decidim_awesome/awesome_map/utilities
// = require decidim/decidim_awesome/awesome_map/markers
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
    hashtags,
    categories
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
              drawMarker(element, marker, component).addTo(layers.proposals.group)
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
            if(hashtags.length) {
              // Add hashtags layers
              addHashtagsControls(map);
            }
          });
        }

        if(options.menu.meetings && component.type == "meetings") {
          addMeetingsControls(map, component);

        fetchMeetings(component, '', (element, marker) => {
          drawMarker(element, marker, component).addTo(layers.meetings.group);
        }, () => autoResizeMap(map) );
      }
    });

    // add categories control layers
    if(categories.length) {
      addCategoriesControls(map);
    }
  };

  $("#map").on("ready.decidim", (_e, map) => {
    if(options.center) {
      map.setView(options.center, options.zoom);
    }
    loadElements(map);
  });

})(window);
