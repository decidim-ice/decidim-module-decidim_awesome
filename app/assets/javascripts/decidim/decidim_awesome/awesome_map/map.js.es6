// = require decidim/map
// = require leaflet.featuregroup.subgroup
// = require decidim/decidim_awesome/awesome_map/categories
// = require decidim/decidim_awesome/awesome_map/proposals
// = require decidim/decidim_awesome/awesome_map/meetings
// = require_self

((exports) => {
  const { fetchProposals, fetchMeetings, Categories } = exports.AwesomeMap;

  const components = $("#map").data("components");
  const popupMeetingTemplateId = "marker-meeting-popup";
  const popupProposalTemplateId = "marker-proposal-popup";

  const cluster = L.markerClusterGroup();
  
  const layers = { 
    meetings: {
      label: "Meetings",
      group: L.featureGroup.subGroup(cluster)
    },
    proposals: {
      label: "Proposals<hr><b>Categories</b>",
      group: L.featureGroup.subGroup(cluster)
    }
  };

  const allMarkers = [];

  const drawMarker = (element, marker, component) => {
    let layer, tmpl, node = document.createElement("div");

    if(component.type === "proposals") {
      tmpl = popupProposalTemplateId;
      layer = layers.proposals;
    } else {
      tmpl = popupMeetingTemplateId;
      layer = layers.meetings;
    }

    $.tmpl($(`#${tmpl}`), element).appendTo(node);
    
    marker.bindPopup(node, {
      maxwidth: 640,
      minWidth: 500,
      keepInView: true,
      className: "map-info"
    }).openPopup();

    marker.addTo(layer.group);
    
    allMarkers.push({
      marker: marker,
      component: component,
      element: element
    });
  };

  const loadElements = (map) => {
    // legends
    const control = L.control.layers(null, null, {position: 'topleft', collapsed: false});
    control.addOverlay(layers.meetings.group, layers.meetings.label);
    control.addOverlay(layers.proposals.group, layers.proposals.label);
    control.addTo(map);

    cluster.addTo(map);
    layers.meetings.group.addTo(map);
    layers.proposals.group.addTo(map);

    // Load markers
    components.forEach((component) => {  
      if(component.type == "proposals") {
        fetchProposals(component, '', (element, marker) => {
          drawMarker(element, marker, component);
        });
      }
      
      if(component.type == "meetings") {
        fetchMeetings(component, '', (element, marker) => {
          drawMarker(element, marker, component);
        });
      }
    });

    // rebuild markers when new categories to ensure vibrant colors
    Categories.onRebuild = () => {
      allMarkers.forEach((item) => {
        item.marker._icon.firstChild.firstChild.style.fill = Categories.get(item.element.category).color
      });
    };

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
