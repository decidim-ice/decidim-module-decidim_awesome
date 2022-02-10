import * as L from "leaflet";
import Controller from "src/decidim/decidim_awesome/awesome_map/controllers/controller";
import ProposalsFetcher from "src/decidim/decidim_awesome/awesome_map/api/proposals_fetcher";

const ProposalIcon = L.DivIcon.SVGIcon.DecidimIcon.extend({
  options: {
    fillColor: "#ef604d",
    fillOpacity: 0.8,
    strokeWidth: 1,
    strokeOpcacity: 1
  }
});
export default class ProposalsController extends Controller {
  constructor(awesomeMap, component) {
    super(awesomeMap, component)
    this.templateId = "marker-proposal-popup";
    this.amendments = {};
    this.setFetcher(ProposalsFetcher);
  }

  addControls() {
    super.addControls();

    // add control layer for amendments if any
    if(this.awesomeMap.config.menu.amendments && this.component.amendments && !this.awesomeMap.layers.amendments) {
      this.awesomeMap.layers.amendments = {
        label: `<span class="awesome_map-component" id="awesome_map-amendments_${this.component.id}" title="0" data-layer="amendments">${window.DecidimAwesome.texts.amendments}</span>`,
        group: new L.FeatureGroup.SubGroup(this.awesomeMap.cluster)
      }
      this.awesomeMap.controls.main.addOverlay(this.awesomeMap.layers.amendments.group, this.awesomeMap.layers.amendments.label);
      this.awesomeMap.layers.amendments.group.addTo(this.awesomeMap.map);
    }
  }

  loadNodes() {
    // for each proposal, create a marker with an associated popup
    this.fetcher.onNode = (proposal) => {
      let marker = new L.Marker([proposal.coordinates.latitude, proposal.coordinates.longitude], {
        icon: this.createIcon(ProposalIcon, this.awesomeMap.getCategory(proposal.category).color),
        title: proposal.title.translation
      });

      // Check if it has amendments, add it to a list
      // also assign parent's proposal categories to it
      if(proposal.amendments && proposal.amendments.length) {
        proposal.amendments.forEach((amendment) => {
          this.amendments[amendment.emendation.id] = proposal;
        });
      }

      // console.log("new proposal", proposal, "marker",  marker)
      this.addMarker(marker, proposal);
    };

    this.fetcher.fetch();
  }

  _onFinished() {
    const iterableAmendments = Object.entries(this.amendments);
    this.awesomeMap.controls.updateStats(`component_${this.component.id}`, this.allMarkers.length - iterableAmendments.length);
    this.awesomeMap.controls.updateStats(`amendments_${this.component.id}`, iterableAmendments.length);

    // Process all amendments
    iterableAmendments.forEach((amendment) => {
      const marker = this.allMarkers.find((item) => item.node.id == amendment[0]);
      const parent = amendment[1];
      // console.log("marker", marker, "parent proposal", parent)
      // add marker to amendments layers and remove it from proposals
      if(marker) {
        try { marker.marker.removeFrom(this.controls.group) } catch(e) { console.error("error removeFrom marker", marker, "layer", this.controls.group,  e)}
        if(this.awesomeMap.config.menu.amendments) {
          marker.marker.addTo(this.awesomeMap.layers.amendments.group);
          // mimic parent category (amendments doesn't have categories)
          if(parent.category) {
            marker.marker.setIcon(this.createIcon(ProposalIcon, this.awesomeMap.getCategory(parent.category).color));
            this.addMarkerCategory(marker.marker, parent.category)
          }
        }
      }
    });

    this.onFinished();
  }
}
