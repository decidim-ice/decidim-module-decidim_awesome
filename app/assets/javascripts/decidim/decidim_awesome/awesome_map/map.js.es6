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

  const layers = {};

  const control = L.control.layers(null, null, {position: 'topleft', collapsed: false});
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

    return marker;
  };

  const loadElements = (map) => {
    // legends
    control.addTo(map);
    cluster.addTo(map);

    // Load markers
    components.forEach((component) => {  
      if(component.type == "proposals") {
        layers.proposals = {
          label: window.DecidimAwesome.texts.proposals,
          group: L.featureGroup.subGroup(cluster) 
        };
        control.addOverlay(layers.proposals.group, layers.proposals.label);
        layers.proposals.group.addTo(map);

        fetchProposals(component, '', (element, marker) => {
          drawMarker(element, marker, component).addTo(layers.proposals.group);
          // add amendments layer if there are some
          if(!layers.amendments && element.amendments.length) {
            layers.amendments = {
              label: window.DecidimAwesome.texts.amendments,
              group: L.featureGroup.subGroup(cluster)
            }
            control.addOverlay(layers.amendments.group, layers.amendments.label);
            layers.amendments.group.addTo(map);
          }
        });
      }
      
      if(component.type == "meetings") {
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

    // place markers on categories subgroups and assign the new calculated color
    Categories.onRebuild = () => {
      let initiated = false,
          lastLayer = layers[Object.keys(layers)[Object.keys(layers).length - 1]];

      allMarkers.forEach((item) => {
        if(!item.element.category) return;
        let cat = Categories.get(item.element.category);
        let newIcon = new item.marker.options.icon.constructor({fillColor: cat.color});
        let layer = layers[cat.id];

        item.marker.setIcon(newIcon);
        // add CSS var
        document.documentElement.style.setProperty(`--awesome_map-category_${cat.id}`, cat.color);
        if(!layer) {
          // Add Categories "title"
          if(lastLayer && !initiated) {
            lastLayer.label = `${lastLayer.label}<hr><b>${window.DecidimAwesome.texts.categories}</b>`;
            control.removeLayer(lastLayer.group);
            control.addOverlay(lastLayer.group, lastLayer.label);
            initiated = true;
          }
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
          item.marker.removeFrom(layers.proposals.group);
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
