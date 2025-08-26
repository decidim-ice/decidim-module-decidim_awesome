import * as L from "leaflet";
// comes with Decidim
import "leaflet-tilelayer-here"
// Comes with Decidim
import "leaflet.markercluster";
// included in this package.json
import "leaflet.featuregroup.subgroup"
import "src/vendor/jquery.truncate"
import "jsrender"

import ControlsUI from "src/decidim/decidim_awesome/awesome_map/controls_ui";
import ProposalsController from "src/decidim/decidim_awesome/awesome_map/controllers/proposals_controller";
import MeetingsController from "src/decidim/decidim_awesome/awesome_map/controllers/meetings_controller";

export default class AwesomeMap {
  constructor(map, config) {
    this.map = map;
    this.taxonomies = window.AwesomeMap && window.AwesomeMap.taxonomies || []
    this.config = $.extend({
      length: 255,
      center: null,
      zoom: 8,
      menu: {
        amendments: false,
        meetings: false,
        categories: true,
        hashtags: false,
        mergeComponents: false
      },
      show: {
        withdrawn: false,
        accepted: false,
        evaluating: false,
        notAnswered: false,
        rejected: false
      },
      hideControls: false,
      collapsedMenu: false,
      components: []
    }, config);
    this.layers = {};
    this.cluster = new L.MarkerClusterGroup();
    this.map.addLayer(this.cluster);
    this.controls = new ControlsUI(this);
    this.onFinished = () => {};
    this.controllers = {};
    this.loading = [];
    this._firstController = {};
  }

  // Queries the API and load all the markers
  loadControllers() {
    this.autoResize();
    this.controls.attach();

    this.config.components.forEach((component) => {
      const controller = this._getController(component);
      if (controller) {
        controller.loadNodes();
        this.loading.push(component.type);
        controller.onFinished = () => {
          this.loading.pop();
          this.autoResize();

          if (this.loading.length === 0) {
            this.controls.loading.style.display = "none";
            // call trigger as all loads are finished
            this.onFinished();
          }
        };
      }
    });
  }

  autoResize() {
    // Setup center/zoom options if specified, otherwise fitbounds
    const bounds = this.cluster.getBounds()
    if (this.config.center && this.config.zoom) {
      this.map.setView(this.config.center, this.config.zoom);
    } else if (bounds.isValid()) {
      // this.map.fitBounds(bounds, { padding: [50, 50] }); // this doesn't work much of the time, probably some race condition
      this.map.fitBounds([[bounds.getNorth(), bounds.getEast()], [bounds.getSouth(), bounds.getWest()]], { padding: [50, 50] });
    }
  }

  getTaxonomy(taxonomy) {
    let defaultTax = {
      color: getComputedStyle(document.documentElement).getPropertyValue("--primary"),
      children: () => {},
      parent: null,
      name: null
    };

    if (taxonomy) {
      let id = taxonomy.id ? parseInt(taxonomy.id, 10) : parseInt(taxonomy, 10); // eslint-disable-line no-ternary, multiline-ternary
      let tax = this.taxonomies.find((tx) => tx.id === id);
      if (tax) {
        tax.children = () => {
          return this.taxonomies.filter((tx) => tx.parent === tax.id);
        }
        return tax;
      }
    }
    return defaultTax;
  }

  _getController(component) {
    let controller = null;

    if (component.type === "proposals") {
      controller = new ProposalsController(this, component);
    }
    if (component.type === "meetings" && this.config.menu.meetings) {
      controller = new MeetingsController(this, component);
    }

    if (controller) {
      // Agrupate layers for controlling components
      if (this._firstController[component.type] && this.config.menu.mergeComponents) {
        controller.controls = this._firstController[component.type].controls;
      } else  {
        controller.addControls();
      }
      this._firstController[component.type] = this._firstController[component.type] || controller;
      this.controllers[component.type] = controller;
      return this.controllers[component.type]
    }
    return null;
  }
}
