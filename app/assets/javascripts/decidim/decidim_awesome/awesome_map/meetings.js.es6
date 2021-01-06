// = require decidim/decidim_awesome/awesome_map/api_fetcher
// = require decidim/decidim_awesome/awesome_map/categories

((exports) => {
  const { getCategory } = exports.AwesomeMap;
  const query = `query ($id: ID!, $after: String!) {
    component(id: $id) {
        id
        __typename
        ... on Meetings {
          meetings(first: 50, after: $after) {
            pageInfo {
              hasNextPage
              endCursor
            }
            edges {
              node {
                id
                title {
                  translations {
                    text
                    locale
                  }
                }
                description {
                  translations {
                    text
                    locale
                  }
                }
                startTime
                location {
                  translations {
                    text
                    locale
                  }
                }
                address
                locationHints {
                  translations {
                    text
                    locale
                  }
                }
                coordinates {
                  latitude
                  longitude
                }
                category {
                  id
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
      iconSize: {x: 300, y:150},
      opacity: 0
    },
    _createPathDescription: function() {
      return "M 15.991543,4 C 7.3956015,4 2.9250351,10.5 3.000951,16.999999 3.1063486,26.460968 12.747693,30.000004 15.991543,43 19.242091,30.000004 29,26.255134 29,16.999999 29,10.5 23.951131,4 15.996007,4 m -0.153508,2.6000001 a 2.1720294,2.1076698 0 0 1 2.330514,2.1124998 2.177008,2.1125006 0 0 1 -4.354016,0 2.1720294,2.1076698 0 0 1 2.023502,-2.1124998 m -2.651707,4.8056679 h 5.610202 l 3.935584,7.569899 -1.926038,0.934266 -2.009546,-3.859265 v 14.557403 h -2.484243 v -9.126003 h -0.642162 v 9.126003 H 13.190347 V 16.050568 l -2.009545,3.859265 -1.926036,-0.934266 3.935581,-7.569899";
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
    const marker = L.marker([element.coordinates.latitude, element.coordinates.longitude], {
      icon: new MeetingIcon({
        fillColor: getCategory(element.category).color
      })
    });

    element.title.translation = ApiFetcher.findTranslation(element.title.translations);
    element.description.translation = ApiFetcher.findTranslation(element.description.translations).replace(/\n/g, "<br>");;
    element.location.translation = ApiFetcher.findTranslation(element.location.translations);
    element.locationHints.translation = ApiFetcher.findTranslation(element.locationHints.translations);
    callback(element, marker);
  };

  const fetchMeetings = (component, after, callback, finalCall = () => {}) => {
    
    const variables = {
      "id": component.id,
      "after": after
    };
    const api = new ApiFetcher(query, variables);
    api.fetchAll((result) => {
      if(result) {
        result.component.meetings.edges.forEach((element) => {
          if(!element.node) return;
          
          if(element.node.coordinates) {
            element.node.link = component.url + '/meetings/' + element.node.id;
            createMarker(element.node, callback);
          }
        });

        if (result.component.meetings.pageInfo.hasNextPage) {
          fetchMeetings(component, result.component.meetings.pageInfo.endCursor, callback, finalCall);
        } else {
          finalCall();
        }
      }
    });
  };

  exports.AwesomeMap = exports.AwesomeMap || {};
  exports.AwesomeMap.fetchMeetings = fetchMeetings;
})(window);
