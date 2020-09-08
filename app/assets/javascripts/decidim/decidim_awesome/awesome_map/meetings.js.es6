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

  const createMarker = (element, callback) => {
    const marker = L.marker([element.coordinates.latitude, element.coordinates.longitude], {
      icon: new L.DivIcon.SVGIcon.DecidimIcon()
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
        console.log("get node", element)
        if(element.node.coordinates) {
          createMarker(element.node, callback);
        }
      })
    });
  };

  exports.AwesomeMap = exports.AwesomeMap || {};
  exports.AwesomeMap.fetchMeetings = fetchMeetings;
})(window);
