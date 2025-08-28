import * as L from "leaflet";
import Controller from "src/decidim/decidim_awesome/awesome_map/controllers/controller";
import ProposalsFetcher from "src/decidim/decidim_awesome/awesome_map/api/proposals_fetcher";

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
    if (this.awesomeMap.config.menu.amendments && this.component.amendments && !this.awesomeMap.layers.amendments) {
      this.awesomeMap.layers.amendments = {
        label: `<span class="awesome_map-component" id="awesome_map-amendments_${this.component.id}" title="0" data-layer="amendments">${window.DecidimAwesome.i18n.amendments}</span>`,
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
        icon: this.createIcon(this.awesomeMap.getTaxonomy(proposal.taxonomies && proposal.taxonomies[0]).color),
        title: proposal.title.translation
      });

      // Check if it has amendments, add it to a list
      // also assign parent's proposal taxonomies to it
      // console.log("onNode proposal", proposal, "amendment:", proposal.amendments)
      if (proposal.amendments && proposal.amendments.length) {
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
    this.awesomeMap.controls.updateStats(`component_${this.component.id}`, this.allNodes.length - iterableAmendments.length);
    this.awesomeMap.controls.updateStats(`amendments_${this.component.id}`, iterableAmendments.length);

    // Process all amendments
    iterableAmendments.forEach((amendment) => {
      const marker = this.allNodes.find((node) => node.id === amendment[0]);
      const parent = amendment[1];
      // console.log("marker", marker, "parent proposal", parent)
      // add marker to amendments layers and remove it from proposals
      if (marker) {
        try {
          marker.marker.removeFrom(this.controls.group)
        } catch (evt) {
          console.error("error removeFrom marker", marker, "layer", this.controls.group,  evt);
        }
        if (this.awesomeMap.config.menu.amendments) {
          marker.marker.addTo(this.awesomeMap.layers.amendments.group);
          // mimic parent taxonomy (amendments doesn't have taxonomies)
          if (parent.taxonomy) {
            marker.marker.setIcon(this.createIcon("text-secondary"));
            this.addMarkerTaxonomy(marker.marker, parent.taxonomy)
          }
        }
      }
    });

    this.onFinished();
  }
}
