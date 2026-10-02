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
                  proposalState {
                    title {
                      translations {
                        text
                        locale
                      }
                    }
                    bgColor
                    textColor
                  }
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
                  likesCount
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
                  taxonomies {
                    id
                  }
                }
              }
            }
          }
        }
      }`;
  }

  decorateNode(node) {
    super.decorateNode(node);
    node.authorName = node.author && node.author.name || window.DecidimAwesome.i18n.officialAuthor;
    const proposalState = node.proposalState;
    node.humanState = "";
    node.stateClass = "muted";
    node.stateStyle = "";
    if (proposalState) {
      node.humanState = this.findTranslation(proposalState.title.translations);
      node.stateClass = "";
      node.stateStyle = `background-color: ${proposalState.bgColor}; color: ${proposalState.textColor}; border-color: ${proposalState.textColor};`;
    }

    node.isAmendment = () => (Boolean(this.controller.amendments[node.id]));
  }
}
