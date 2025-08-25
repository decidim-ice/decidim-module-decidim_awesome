import * as L from "leaflet";

export default class Controller {
  constructor(awesomeMap, component) {
    this.awesomeMap = awesomeMap;
    this.component = component;
    this.templateId = "marker-meeting-popup";
    this.controls = {
      label: this.getLabel(),
      group: new L.FeatureGroup.SubGroup(this.awesomeMap.cluster)
    };
    this.onFinished = () => {};
    this.allNodes = [];
  }

  getLabel() {
    let text = this.component.name;
    if (!text || this.awesomeMap.config.menu.mergeComponents) {
      text = window.DecidimAwesome.i18n[this.component.type];
    }
    return `<span class="awesome_map-component" id="awesome_map-component_${this.component.id}" title="0" data-layer="${this.component.type}">${text}</span>`
  }

  setFetcher(Fetcher) {
    let checkProposalState = function (node, map) {
      const showConfig = map.config.show;
      return showConfig[node.state || "notAnswered"];
    }

    this.fetcher = new Fetcher(this);
    this.fetcher.onFinished = () => {
      // console.log(`all ${this.component.type} loaded`, this)
      this._onFinished();
    };
    this.fetcher.onCollection = (collection) =>  {
      if (collection && collection.edges)  {
        // Add markers to the main cluster group
        let collectionEdges = [];
        if (this.fetcher.collection === "meetings") {
          collectionEdges = collection.edges.filter((item) => item.node.coordinates && item.node.coordinates.latitude && item.node.coordinates.longitude);
        } else {
          collectionEdges = collection.edges.filter((item) => item.node.coordinates && item.node.coordinates.latitude && item.node.coordinates.longitude && checkProposalState(item.node, this.awesomeMap));
        }

        try {
          this.awesomeMap.cluster.addLayers(collectionEdges.map((item) => item.node.marker));
        } catch (evt) {
          console.error("Failed marker collection assignation", collectionEdges, "error", evt);
        }
        // subgroups don't have th addLayers utility
        collectionEdges.forEach((item) => {
          this.awesomeMap.layers[this.component.type].group.addLayer(item.node.marker);
          if (item.node.taxonomies && item.node.taxonomies.length > 0) {
            item.node.taxonomies.forEach((taxonomy) => {
              this.addMarkerTaxonomy(item.node.marker, taxonomy);
            });
          }
          this.addMarkerHashtags(item.node.marker, item.node.hashtags);
        });
      }
    };
  }

  addControls() {
    this.awesomeMap.controls.main.addOverlay(this.controls.group, this.controls.label);
    this.controls.group.addTo(this.awesomeMap.map);
    this.awesomeMap.layers[this.component.type] = this.controls;
  }

  loadNodes() {
    // to override
  }

  addMarker(marker, node) {

    /*
    theorically, this should be enough to create popups on markers but it looks that
    there is some bug in leaflet that sometimes prevents this to work
    */
    /*
    let dom = document.createElement("div");
    // console.log("addMarker", marker, "dom", dom)
    dom.innerHTML = $.templates(`#${this.templateId}`).render(node);
    marker.bindPopup(dom, {
      maxwidth: 640,
      minWidth: 500,
      keepInView: true,
      className: "map-info"
    }); //*/

    marker.on("click", () => {
      let dom = document.createElement("div");
      dom.innerHTML = $.templates(`#${this.templateId}`).render(node);

      let pop = L.popup({
        maxwidth: 640,
        minWidth: 500,
        keepInView: true,
        className: "map-info"

      }).setLatLng(marker.getLatLng()).setContent(dom);
      this.awesomeMap.map.addLayer(pop);
      // console.log("marker click", node, "pop", pop, "marker", marker, "dom", dom, "templateId", this.templateId)
    });
    node.marker = marker;
    node.component = this.component;
    this.allNodes.push(node);
  }

  addMarkerCategory(marker, category) {
    // Add to category layer
    const cat = this.awesomeMap.getCategory(category);
    if (this.awesomeMap.layers[cat.id]) {
      try {
        this.awesomeMap.layers[cat.id].group.addLayer(marker);
        this.awesomeMap.controls.showCategory(cat);
      } catch (evt) {
        console.error("Failed category marker assignation. category:", category, "marker:", marker, evt.message);
      }
    }
  }

  addMarkerTaxonomy(marker, taxonomy) {
    const tax = this.awesomeMap.getTaxonomy(taxonomy);
    if (this.awesomeMap.layers[tax.id]) {
      try {
        this.awesomeMap.layers[tax.id].group.addLayer(marker);
        this.awesomeMap.controls.showCategory(tax);
      } catch (evt) {
        console.error("Failed taxonomy marker assignation. taxonomy:", taxonomy, "marker:", marker, evt.message);
      }
    }
  }

  addMarkerHashtags(marker, hashtags) {
    // Add hashtag layer
    if (this.awesomeMap.config.menu.hashtags) {
      try {
        this.awesomeMap.controls.addHashtagsControls(hashtags, marker);
      } catch (evt) {
        console.error("Failed hashtags marker assignation. hashtags:", hashtags, "marker:", marker, evt.message);
      }
    }
  }

  // Override if needed (call this.onFinished() at the end!)
  _onFinished() {
    this.awesomeMap.controls.updateStats(`component_${this.component.id}`, this.allNodes.length);
    this.onFinished();
  }

  createIcon(color) {
    const size = 36;
    return L.divIcon({
      html: `
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="${size}px" height="${size}px" class="text-secondary" style="color: ${color}"><path fill="none" d="M0 0h24v24H0z"/><path fill="currentColor" d="M18.364 17.364L12 23.728l-6.364-6.364a9 9 0 1 1 12.728 0zM12 15a4 4 0 1 0 0-8 4 4 0 0 0 0 8zm0-2a2 2 0 1 1 0-4 2 2 0 0 1 0 4z"/></svg>`,
      iconAnchor: [0.5 * size, size],
      popupAnchor: [0, -0.5 * size]
    });
  }
}
