import Fetcher from "src/decidim/decidim_awesome/awesome_map/api/fetcher";

export default class MeetingsFetcher extends Fetcher {
  constructor(controller) {
    super(controller);
    this.query = `query ($id: ID!, $after: String!) {
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
                body: description {
                  translations {
                    text
                    locale
                  }
                }
                startTime
                endTime
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
                typeOfMeeting
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
