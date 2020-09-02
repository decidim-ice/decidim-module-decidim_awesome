// = require leaflet
// = require leaflet-svg-icon
// = require leaflet.markercluster
// = require jquery-tmpl
// = require_self

L.DivIcon.SVGIcon.DecidimIcon = L.DivIcon.SVGIcon.extend({
  options: {
    fillColor: "#ef604d",
    opacity: 0
  },
  // Improved version of the _createSVG, essentially the same as in later
  // versions of Leaflet. It adds the `px` values after the width and height
  // CSS making the focus borders work correctly across all browsers.
  _createSVG: function() {
    const path = this._createPath();
    const circle = this._createCircle();
    const text = this._createText();
    const className = `${this.options.className}-svg`;

    const style = `width:${this.options.iconSize.x}px; height:${this.options.iconSize.y}px;`;

    const svg = `<svg xmlns="http://www.w3.org/2000/svg" version="1.1" class="${className}" style="${style}">${path}${circle}${text}</svg>`;

    return svg;
  }
});

const popupMeetingTemplateId = "marker-meeting-popup";
$meetingTmpl = $.template(popupMeetingTemplateId, $(`#${popupMeetingTemplateId}`).html());

const popupProposalTemplateId = "marker-proposal-popup";
$proposalTmpl = $.template(popupProposalTemplateId, $(`#${popupProposalTemplateId}`).html());

let markerClusters = L.markerClusterGroup();

function printQuery(data, map) {
  var participatory_process = data.participatoryProcess;
  var markerData = [];

  if (participatory_process.hasOwnProperty("components")) {
    participatory_process.components.forEach(element => {
 

      if (element.__typename == "Meetings") {
        element.meetings.edges.forEach(edge => {

          var marker = L.marker([edge.node.coordinates.latitude, edge.node.coordinates.longitude], {
            icon: new L.DivIcon.SVGIcon.DecidimIcon()
          });
          let node = document.createElement("div");
          edge.node.link = '/processes/' + participatory_process.slug + '/f/' + element.id + '/meetings/' + edge.node.id;

          $.tmpl($(`#${popupMeetingTemplateId}`), edge.node).appendTo(node);

          marker.bindPopup(node, {
            maxwidth: 640,
            minWidth: 500,
            keepInView: true,
            className: "map-info"
          }).openPopup();
      
          marker.addTo(map);
          markerClusters.addLayer(marker);
        });
      } else if (element.__typename == "Proposals") {
      
        element.proposals.edges.forEach(edge => {
          
          var marker = L.marker([edge.node.coordinates.latitude, edge.node.coordinates.longitude], {
            icon: new L.DivIcon.SVGIcon.DecidimIcon()
          });
          var node = document.createElement("div");
          edge.node.link = '/processes/' + participatory_process.slug + '/f/' + element.id + '/proposals/' + edge.node.id;
          $.tmpl($(`#${popupProposalTemplateId}`), edge.node).appendTo(node);
      
          marker.bindPopup(node, {
            maxwidth: 640,
            minWidth: 500,
            keepInView: true,
            className: "map-info"
          }).openPopup();
      
          markerClusters.addLayer(marker);
        });
      }
    });
  }

    map.addLayer(markerClusters);
    // map.fitBounds(bounds, { padding: [100, 100] });
}

$(() => {
  const mapId = "awesome-map";
  const $map = $(`#${mapId}`);
  const participatory_space = $map.data('participatory_space');

  var graphql_query = 'query ($participatory_space: String!, $lang: String!)\
    {\
      participatoryProcess(slug: $participatory_space) {\
        id\
        slug\
        components(filter: {withGeolocationEnabled: true}) {\
          id\
          __typename\
          ... on Meetings {\
            meetings {\
              edges {\
                node {\
                  id\
                  title {\
                    translation (locale: $lang)\
                  }\
                  description {\
                    translation (locale: $lang)\
                  }\
                  startTime\
                  location {\
                    translation (locale: $lang)\
                  }\
                  address\
                  locationHints {\
                    translation (locale: $lang)\
                  }\
                  coordinates {\
                    latitude\
                    longitude\
                  }\
                }\
              }\
            }\
          }\
          ... on Proposals {\
            proposals {\
              edges {\
                node {\
                  id\
                  title\
                  body\
                  address\
                  coordinates {\
                    latitude\
                    longitude\
                  }\
                }\
              }\
            }\
          }\
        }\
      }\
    }';

  var map = L.map('awesome-map').setView({lon: 0, lat: 0}, 2);

  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; <a href="https://openstreetmap.org/copyright">OpenStreetMap contributors</a>'
  }).addTo(map);

  $.ajax({
    method: "POST",
    url: "/api",
    contentType: "application/json",
    data: JSON.stringify({
      query: graphql_query,
      variables: {
        "participatory_space": participatory_space,
        "lang": document.querySelector('html').getAttribute('lang') 
      }
    })
  }).done(function(data) {
    printQuery(data.data, map);
  });
  
});

