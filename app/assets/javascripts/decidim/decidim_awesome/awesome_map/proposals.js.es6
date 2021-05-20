// = require decidim/decidim_awesome/awesome_map/api_fetcher
// = require decidim/decidim_awesome/awesome_map/categories
// = require decidim/decidim_awesome/awesome_map/hashtags
// = require decidim/decidim_awesome/awesome_map/utilities

((exports) => {
  const { getCategory, truncate, collectHashtags, removeHashtags, appendHtmlHashtags } = exports.AwesomeMap;
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
                state
                title {
                  translations {
                    text
                    locale
                  }
                }
                body {
                  translations {
                    text
                    locale
                  }
                }
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

  let amendments = [];
  const ProposalIcon = L.DivIcon.SVGIcon.DecidimIcon;

  const createMarker = (element, callback) => {
    const marker = L.marker([element.coordinates.latitude, element.coordinates.longitude], {
      icon: new ProposalIcon({
        fillColor: getCategory(element.category).color
      })
    });

    element.title.translation = ApiFetcher.findTranslation(element.title.translations);
    const body = ApiFetcher.findTranslation(element.body.translations);
    element.hashtags = collectHashtags(body);
    element.body.translation = appendHtmlHashtags(truncate(removeHashtags(body)).replace(/\n/g, "<br>"), element.hashtags);

    callback(element, marker);
  };

  const fetchProposals = (component, after, callback, finalCall = () => {}) => {
    const variables = {
      "id": component.id,
      "after": after
    };
    const api = new ApiFetcher(query, variables);
    api.fetchAll((result) => {
      if(result) {
        result.component.proposals.edges.forEach((element) => {
          if(!element.node) return;

          if(element.node.coordinates && element.node.coordinates.latitude && element.node.coordinates.longitude) {
            element.node.link = component.url + '/proposals/' + element.node.id;
            createMarker(element.node, callback);
          }

          // Check if it has amendments, add it to a list
          if(element.node.amendments && element.node.amendments.length) {
            element.node.amendments.forEach((amendment) => {
              amendments.push(amendment.emendation.id);
            });
          }
        });
        if (result.component.proposals.pageInfo.hasNextPage) {
          fetchProposals(component, result.component.proposals.pageInfo.endCursor, callback, finalCall);
        } else {
          finalCall();
        }
      }
    });
  };

  exports.AwesomeMap = exports.AwesomeMap || {};
  exports.AwesomeMap.fetchProposals = fetchProposals;
  exports.AwesomeMap.amendments = amendments;
})(window);
