// = require decidim/decidim_awesome/awesome_map/api_fetcher

((exports) => {
  const query = `query ($id: ID!) {
    component(id: $id) {
        id
        __typename
        ... on Proposals {
          proposals {
            edges {
              node {
                id
                title
                body
                address
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

  const fetchProposals = (component, callback) => {    
    const variables = {
      "id": component
    };
    const api = new ApiFetcher(query, variables);
    api.fetchAll((result) => {
      result.component.proposals.edges.forEach((element) => {
        if(element.node.coordinates) {
          createMarker(element.node, callback);
        }
      })
    });
  };

  exports.AwesomeMap = exports.AwesomeMap || {};
  exports.AwesomeMap.fetchProposals = fetchProposals;
})(window);
