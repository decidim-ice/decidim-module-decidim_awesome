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
        icon: this.createIcon(this.awesomeMap.getCategory(meeting.category).color),
        title: meeting.title.translation
      });
      // console.log("new meeting", meeting, marker)
      this.addMarker(marker, meeting);
    };

    this.fetcher.fetch();
  }

  createIcon(color) {
    const size = 36;
    return L.divIcon({
      html: `
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 36 36" width="${size}px" height="${size}px" class="text-primary" style="color: ${color}"><path fill="none" d="M0 0h24v24H0z"/><path fill="currentColor" d="M 15.991543,4 C 7.3956015,4 2.9250351,10.5 3.000951,16.999999 3.1063486,26.460968 12.747693,30.000004 15.991543,43 19.242091,30.000004 29,26.255134 29,16.999999 29,10.5 23.951131,4 15.996007,4 m -0.153508,2.6000001 a 2.1720294,2.1076698 0 0 1 2.330514,2.1124998 2.177008,2.1125006 0 0 1 -4.354016,0 2.1720294,2.1076698 0 0 1 2.023502,-2.1124998 m -2.651707,4.8056679 h 5.610202 l 3.935584,7.569899 -1.926038,0.934266 -2.009546,-3.859265 v 14.557403 h -2.484243 v -9.126003 h -0.642162 v 9.126003 H 13.190347 V 16.050568 l -2.009545,3.859265 -1.926036,-0.934266 3.935581,-7.569899"/></svg>`,
      iconAnchor: [0.5 * size, size],
      popupAnchor: [0, -0.5 * size]
    });
  }
}
