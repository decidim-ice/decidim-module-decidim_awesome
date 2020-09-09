// = require decidim/decidim_awesome/awesome_map/api_fetcher

((exports) => {
  const query = `query ($id: ID!, $lang: String!, $after: String!) {
    component(id: $id) {
        id
        __typename
        ... on Meetings {
          meetings(first: 10, after: $after) {
            pageInfo {
              hasNextPage
              endCursor
            }
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

  const fetchMeetings = (component, after, callback) => {
    
    const variables = {
      "id": component,
      "lang": document.querySelector('html').getAttribute('lang') ,
      "after": after
    };
    const api = new ApiFetcher(query, variables);
    api.fetchAll((result) => {
      if (result.component.meetings.pageInfo.hasNextPage) {
        fetchProposals(component, result.component.meetings.pageInfo.endCursor, callback);
      }
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
