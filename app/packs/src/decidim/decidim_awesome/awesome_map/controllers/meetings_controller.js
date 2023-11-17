import * as L from "leaflet";
import Controller from "src/decidim/decidim_awesome/awesome_map/controllers/controller";
import MeetingsFetcher from "src/decidim/decidim_awesome/awesome_map/api/meetings_fetcher";

export default class MeetingsController extends Controller {
  constructor(awesomeMap, component) {
    super(awesomeMap, component)
    this.templateId = "marker-meeting-popup";
    this.setFetcher(MeetingsFetcher);
  }

  loadNodes() {
    // for each meeting, create a marker with an associated popup
    this.fetcher.onNode = (meeting) => {
      let marker = new L.Marker([meeting.coordinates.latitude, meeting.coordinates.longitude], {
        icon: this.createIcon("text-primary"),
        title: meeting.title.translation
      });
      // console.log("new meeting", meeting, marker)
      this.addMarker(marker, meeting);
    };

    this.fetcher.fetch();
  }
}
