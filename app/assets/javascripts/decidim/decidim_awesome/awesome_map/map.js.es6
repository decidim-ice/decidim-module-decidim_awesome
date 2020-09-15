// = require decidim/map
// = require leaflet.featuregroup.subgroup
// = require decidim/decidim_awesome/awesome_map/categories
// = require decidim/decidim_awesome/awesome_map/proposals
// = require decidim/decidim_awesome/awesome_map/meetings
// = require_self

((exports) => {
  const { fetchProposals, fetchMeetings, getCategory } = exports.AwesomeMap;

  const components = $("#map").data("components");
  const popupMeetingTemplateId = "marker-meeting-popup";
  const popupProposalTemplateId = "marker-proposal-popup";

  const cluster = L.markerClusterGroup();
  const amendments = [];

  const layers = {};

  const control = L.control.layers(null, null, {
    position: 'topleft', 
    // collapsed: false, 
    hideSingleBase: true
  });
  const allMarkers = [];

  const drawMarker = (element, marker, component) => {
    let tmpl = component.type === "proposals" ? popupProposalTemplateId : popupMeetingTemplateId,
        node = document.createElement("div");

    $.tmpl($(`#${tmpl}`), element).appendTo(node);
    
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

    // Check if it has amendments, add it to a list
    if(element.amendments && element.amendments.length) {
      element.amendments.forEach((amendment) => {
        amendments.push(amendment.emendation.id);
      });
    }

    // Add to category layer
    let l = layers[getCategory(element.category).id];
    if(l) {
      marker.addTo(l.group);
      if(!l.added) {
        control.addOverlay(l.group, l.label);
        l.added = true;
      }
    }
    return marker;
  };

  const loadElements = (map) => {
    // legends
    control.addTo(map);
    cluster.addTo(map);

    // Load markers
    components.forEach((component) => {  
      if(component.type == "proposals") {
        // add control layer for proposals
        layers.proposals = {
          label: window.DecidimAwesome.texts.proposals,
          group: L.featureGroup.subGroup(cluster)
        };
        control.addOverlay(layers.proposals.group, layers.proposals.label);
        layers.proposals.group.addTo(map);

        // add control layer for amendments if any
        if(component.amendments) {
          layers.amendments = {
            label: window.DecidimAwesome.texts.amendments,
            group: L.featureGroup.subGroup(cluster)
          }
          control.addOverlay(layers.amendments.group, layers.amendments.label);
          layers.amendments.group.addTo(map);
        }

        fetchProposals(component, '', (element, marker) => {
            drawMarker(element, marker, component).addTo(layers.proposals.group);
          }, () => {
          // finall call
          allMarkers.forEach((item) => {
            // add marker to amendments layers if it's an amendment
            if(amendments.find((a) => a == item.element.id)) {
              item.marker.removeFrom(layers.proposals.group);
              item.marker.addTo(layers.amendments.group);
            }
          });
        });
      }
      
      if(component.type == "meetings") {
        // add control layer for meetings
        layers.meetings = {
          label: window.DecidimAwesome.texts.meetings,
          group: L.featureGroup.subGroup(cluster)
        };
        control.addOverlay(layers.meetings.group, layers.meetings.label);
        layers.meetings.group.addTo(map);
      
        fetchMeetings(component, '', (element, marker) => {
          drawMarker(element, marker, component).addTo(layers.meetings.group);
        });
      }
    });


    // add categories control layers
    if(window.AwesomeMap.categories.length) {
      let lastLayer = layers[Object.keys(layers)[Object.keys(layers).length - 1]];
      // Add Categories "title"
      if(lastLayer) {
        lastLayer.label = `${lastLayer.label}<hr><b>${window.DecidimAwesome.texts.categories}</b>`;
        control.removeLayer(lastLayer.group);
        control.addOverlay(lastLayer.group, lastLayer.label);
      }
      window.AwesomeMap.categories.forEach((category) => {
        // add control layer for this category
        layers[category.id] = {
          label: `<i class="awesome_map-category_${category.id}"></i> ${category.name}`,
          group: L.featureGroup.subGroup(cluster)
        };
        // control.addOverlay(layers[category.id].group, layers[category.id].label);
        layers[category.id].group.addTo(map);
      });
    }
  };

  // currentMap might not be loaded yet so let's delay a bit
  // TODO: improve this
  const waitMap = () => {
    if(exports.Decidim && exports.Decidim.currentMap) {
      loadElements(exports.Decidim.currentMap);
    } else {
      setTimeout(() => {
        waitMap();
      }, 100);
    }
  };

  waitMap();

})(window);
