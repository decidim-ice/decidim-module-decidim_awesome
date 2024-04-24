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
                address
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

  decorateNode(node) {
    super.decorateNode(node);
    node.icon = window.AwesomeMapMeetingTypes[node.typeOfMeeting];
    node.meetingType = window.AwesomeMapMeetingTexts[node.typeOfMeeting];
    node.dateRange = this.formatDateRange(node.startTime, node.endTime);
  }
}
