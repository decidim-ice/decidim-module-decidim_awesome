// = require decidim/decidim_awesome/awesome_map/api_fetcher
// = require decidim/decidim_awesome/awesome_map/categories

((exports) => {
  const { getCategory } = exports.AwesomeMap;
  const query = `query ($id: ID!, $after: String!) {
    component(id: $id) {
        id
        __typename
        ... on Proposals {
          proposals(first: 50, after: $after){
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
                amendments {
                  emendation {
                    id
                  }
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

  const ProposalIcon = L.DivIcon.SVGIcon.DecidimIcon;

  const createMarker = (element, callback) => {
    const marker = L.marker([element.coordinates.latitude, element.coordinates.longitude], {
      icon: new ProposalIcon({
        fillColor: getCategory(element.category).color
      })
    });

    callback(element, marker);
  };

  const fetchProposals = (component, after, callback, finalCall = () => {}) => {
    const variables = {
      "id": component.id,
      "after": after
    };
    const api = new ApiFetcher(query, variables);
    api.fetchAll((result) => {
      result.component.proposals.edges.forEach((element) => {
        if(!element.node) return;
        
        if(element.node.coordinates) {
          element.node.link = component.url + '/proposals/' + element.node.id;
          createMarker(element.node, callback);
        }
      });
      if (result.component.proposals.pageInfo.hasNextPage) {
        fetchProposals(component, result.component.proposals.pageInfo.endCursor, callback, finalCall);
      } else {
        finalCall();
      }
    });
  };

  exports.AwesomeMap = exports.AwesomeMap || {};
  exports.AwesomeMap.fetchProposals = fetchProposals;
})(window);
