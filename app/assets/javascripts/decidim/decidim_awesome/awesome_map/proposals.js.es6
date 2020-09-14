// = require decidim/decidim_awesome/awesome_map/api_fetcher
// = require decidim/decidim_awesome/awesome_map/categories

((exports) => {
  const { Categories } = exports.AwesomeMap;
  const query = `query ($id: ID!, $lang: String!, $after: String!) {
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
                category {
                  id
                  name {
                    translation(locale: $lang)
                  }
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
        fillColor: Categories.get(element.category).color
      })
    });

    callback(element, marker);
  };

  const fetchProposals = (component, after, callback) => {
    const variables = {
      "id": component.id,
      "after": after,
      "lang": document.querySelector('html').getAttribute('lang')
    };
    const api = new ApiFetcher(query, variables);
    api.fetchAll((result) => {
      if (result.component.proposals.pageInfo.hasNextPage) {
        fetchProposals(component, result.component.proposals.pageInfo.endCursor, callback);
      }
      result.component.proposals.edges.forEach((element) => {
        if(element.node.coordinates) {
          element.node.link = component.url + '/proposals/' + element.node.id;
          createMarker(element.node, callback);
        }
      })
    });
  };

  exports.AwesomeMap = exports.AwesomeMap || {};
  exports.AwesomeMap.fetchProposals = fetchProposals;
})(window);
