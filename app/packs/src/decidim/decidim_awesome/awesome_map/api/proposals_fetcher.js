import Fetcher from "src/decidim/decidim_awesome/awesome_map/api/fetcher";

export default class ProposalsFetcher extends Fetcher {
  constructor(controller) {
    super(controller);
    this.query = `query ($id: ID!, $after: String!) {
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
                  author {
                    id
                    name
                  }
                  body {
                    translations {
                      text
                      locale
                    }
                  }
                  totalCommentsCount
                  endorsementsCount
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
  }
}
