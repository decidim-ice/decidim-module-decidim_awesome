// = require decidim/map
// = require leaflet.featuregroup.subgroup
// = require decidim/decidim_awesome/awesome_map/proposals
// = require decidim/decidim_awesome/awesome_map/meetings
// = require_self

((exports) => {
  const { fetchProposals, ProposalIcon, fetchMeetings, MeetingIcon } = exports.AwesomeMap;

  const components = $("#map").data("components");
  const popupMeetingTemplateId = "marker-meeting-popup";
  const popupProposalTemplateId = "marker-proposal-popup";

  const cluster = L.markerClusterGroup();
  
  // TODO: add categories, i18n
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

  const drawMarker = (marker, node, layer) => {
    marker.bindPopup(node, {
      maxwidth: 640,
      minWidth: 500,
      keepInView: true,
      className: "map-info"
    }).openPopup();

    marker.addTo(layer.group);
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
        fetchProposals(component.id, '', (element, marker) => {
          const node = document.createElement("div");
          element.link = component.url + '/proposals/' + element.id;
          $.tmpl($(`#${popupProposalTemplateId}`), element).appendTo(node);

          drawMarker(marker, node, layers.proposals);
        });
      }
      
      if(component.type == "meetings") {
        fetchMeetings(component.id, '', (element, marker) => {
          const node = document.createElement("div");
          element.link = component.url + '/meetings/' + element.id;
          $.tmpl($(`#${popupMeetingTemplateId}`), element).appendTo(node);

          drawMarker(marker, node, layers.meetings);
        });
      }
    });
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
