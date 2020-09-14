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
  const amendments = [];

  // TODO: i18n!!
  const layers = { 
    meetings: {
      label: "Meetings",
      group: L.featureGroup.subGroup(cluster)
    },
    proposals: {
      label: "Proposals",
      group: L.featureGroup.subGroup(cluster)
    },
    amendments: {
      label: "Amendments<hr><b>Categories</b>",
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

    // Check if it has amendments, add it to a list
    if(element.amendments && element.amendments.length) {
      element.amendments.forEach((amendment) => {
        amendments.push(amendment.emendation.id);
      });
    }
  };

  const loadElements = (map) => {
    // legends
    const control = L.control.layers(null, null, {position: 'topleft', collapsed: false});
    control.addOverlay(layers.meetings.group, layers.meetings.label);
    control.addOverlay(layers.proposals.group, layers.proposals.label);
    control.addOverlay(layers.amendments.group, layers.amendments.label);
    control.addTo(map);

    cluster.addTo(map);
    layers.meetings.group.addTo(map);
    layers.proposals.group.addTo(map);
    layers.amendments.group.addTo(map);

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
        let cat = Categories.get(item.element.category);
        let newIcon = new item.marker.options.icon.constructor({fillColor: cat.color});
        let layer = layers[cat.id];

        item.marker.setIcon(newIcon);
        // add CSS var
        document.documentElement.style.setProperty(`--awesome_map-category_${cat.id}`, cat.color);
        if(!layer) {
          // add control layer for this category
          layer = {
            label: `<i style="background-color:var(--awesome_map-category_${cat.id})"></i> ${cat.name}`,
            group: L.featureGroup.subGroup(cluster)
          };
          control.addOverlay(layer.group, layer.label);
          layer.group.addTo(map);
          layers[cat.id] = layer;
        }
        // add marker to its category
        item.marker.addTo(layer.group);
        // add marker to amendments layers if it's an amendment
        if(amendments.find((a) => a == item.element.id)) {
          item.marker.addTo(layers.amendments.group);
        }
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
