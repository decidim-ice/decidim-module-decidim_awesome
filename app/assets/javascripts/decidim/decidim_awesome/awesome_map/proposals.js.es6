// = require decidim/decidim_awesome/awesome_map/api_fetcher

((exports) => {
  const query = `query ($id: ID!, $after: String!) {
    component(id: $id) {
        id
        __typename
        ... on Proposals {
          proposals(first:10, after: $after){
            pageInfo {
              hasNextPage
              endCursor
            }

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

  const fetchProposals = (component, after, callback) => {
    const variables = {
      "id": component,
      "after": after
    };
    const api = new ApiFetcher(query, variables);
    api.fetchAll((result) => {
      if (result.component.proposals.pageInfo.hasNextPage) {
        fetchProposals(component, result.component.proposals.pageInfo.endCursor, callback);
      }
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
