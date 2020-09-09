// = require decidim/decidim_awesome/awesome_map/api_fetcher

((exports) => {
  const query = `query ($id: ID!, $lang: String!) {
    component(id: $id) {
        id
        __typename
        ... on Meetings {
          meetings {
            edges {
              node {
                id
                title {
                  translation (locale: $lang)
                }
                description {
                  translation (locale: $lang)
                }
                startTime
                location {
                  translation (locale: $lang)
                }
                address
                locationHints {
                  translation (locale: $lang)
                }
                coordinates {
                  latitude
                  longitude
                }
              }
            }
          }
        }
      }
    }`;

  const MeetingIcon = L.DivIcon.SVGIcon.extend({
    options: {
      fillColor: "#ef604d",
      opacity: 0
    },
    _createPathDescription: function() {
      return "M 15.989592,0 C 5.4099712,0 -0.09226458,8.0000004 0.00117042,15.999999 0.13089042,27.644267 11.997159,32.000004 15.989592,48 19.990269,32.000004 32,27.390935 32,15.999999 32,8.0000004 25.786006,0 15.995088,0 m -0.188937,3.2000001 a 2.6732672,2.594055 0 0 1 2.868327,2.5999998 2.6793939,2.6000001 0 0 1 -5.358787,0 2.6732672,2.594055 0 0 1 2.49046,-2.5999998 m -3.26364,5.9146668 h 6.904866 l 4.843797,9.3167991 -2.37051,1.149868 -2.473287,-4.749867 V 32.74827 H 16.389846 V 21.516267 H 15.599493 V 32.74827 H 12.541968 V 14.831467 L 10.06868,19.581334 7.6981735,18.431466 12.541968,9.1146669";
    },
    _createCircle: function() {
      return ""
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

  const createMarker = (element, callback) => {
    // let fillColor = // TODO get color from categories;
    const marker = L.marker([element.coordinates.latitude, element.coordinates.longitude], {
      icon: new MeetingIcon({
        // fillColor: fillColor
      })
    });

    callback(element, marker);
  };

  const fetchMeetings = (component, callback) => {
    
    const variables = {
      "id": component,
      "lang": document.querySelector('html').getAttribute('lang') 
    };
    const api = new ApiFetcher(query, variables);
    api.fetchAll((result) => {
      result.component.meetings.edges.forEach((element) => {
        if(element.node.coordinates) {
          createMarker(element.node, callback);
        }
      })
    });
  };

  exports.AwesomeMap = exports.AwesomeMap || {};
  exports.AwesomeMap.fetchMeetings = fetchMeetings;
})(window);
