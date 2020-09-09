// = require decidim/map
// = require decidim/decidim_awesome/awesome_map/proposals
// = require decidim/decidim_awesome/awesome_map/meetings
// = require_self

((exports) => {
  const { fetchProposals, fetchMeetings } = exports.AwesomeMap;

  const components = $("#map").data("components");
  const popupMeetingTemplateId = "marker-meeting-popup";
  const popupProposalTemplateId = "marker-proposal-popup";

  let markerClusters = L.markerClusterGroup();

  const drawMarker = (marker, node, map) => {
    console.log("draw", marker, node)
    marker.bindPopup(node, {
      maxwidth: 640,
      minWidth: 500,
      keepInView: true,
      className: "map-info"
    }).openPopup();

    marker.addTo(map);
    markerClusters.addLayer(marker);
  };

  const loadElements = (map) => {
    map.addLayer(markerClusters);
    
    components.forEach((component) => {
      
      if(component.type == "proposals") {
        fetchProposals(component.id, (element, marker) => {
          console.log("new proposal", marker);
          const node = document.createElement("div");
          element.link = component.url + '/proposals/' + element.id;
          $.tmpl($(`#${popupProposalTemplateId}`), element).appendTo(node);

          drawMarker(marker, node, map);
        });
      }
      
      if(component.type == "meetings") {
        fetchMeetings(component.id, (element, marker) => {
          console.log("new meeting", marker);
          const node = document.createElement("div");
          element.link = component.url + '/meetings/' + element.id;
          $.tmpl($(`#${popupMeetingTemplateId}`), element).appendTo(node);

          drawMarker(marker, node, map);
        });
      }
    });
  };


  // currentMap might not be implemented yet so let's delay a bit
  // TODO: improve this
  setTimeout(() => {
    loadElements(exports.Decidim.currentMap);
  },1000);
  
})(window);
