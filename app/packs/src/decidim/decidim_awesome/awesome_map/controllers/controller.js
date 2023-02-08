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
    let text = this.awesomeMap.config.menu.mergeComponents || !this.component.name 
      ? window.DecidimAwesome.texts[this.component.type]
      : this.component.name;
    return `<span class="awesome_map-component" id="awesome_map-component_${this.component.id}" title="0" data-layer="${this.component.type}">${text}</span>`
  }

  setFetcher(Fetcher) {
    this.fetcher = new Fetcher(this);
    this.fetcher.onFinished = () => {
      // console.log(`all ${this.component.type} loaded`, this)
      this._onFinished();
    };
    this.fetcher.onCollection = (collection) =>  {
      if (collection && collection.edges)  { 
        // Add markers to the main cluster group
        const collectionEdges = collection.edges.filter((item) => item.node.coordinates && item.node.coordinates.latitude && item.node.coordinates.longitude);
        try {
          this.awesomeMap.cluster.addLayers(collectionEdges.map((item) => item.node.marker));
        } catch (e) {
          console.error("Failed marker collection assignation", collectionEdges, "error", e);
        }
        // subgroups don't have th addLayers utility
        collectionEdges.forEach((item) => {
          this.awesomeMap.layers[this.component.type].group.addLayer(item.node.marker);
          this.addMarkerCategory(item.node.marker, item.node.category);
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
      } catch (e) {
        console.error("Failed category marker assignation", marker, e.message);
      }
    }   
  }

  addMarkerHashtags(marker, hashtags) {
    // Add hashtag layer
    if (this.awesomeMap.config.menu.hashtags) {
      try {
        this.awesomeMap.controls.addHashtagsControls(hashtags, marker);
      } catch (e) {
        console.error("Failed hashtags marker assignation", marker, e.message);
      }
    }
  }

  // Override if needed (call this.onFinished() at the end!)
  _onFinished() {
    this.awesomeMap.controls.updateStats(`component_${this.component.id}`, this.allNodes.length);
    this.onFinished();
  }

  createIcon(Builder, color) {
    return new Builder({
      color: "#000000",
      fillColor: color,
      circleFillColor: color,
      weight: 1,
      stroke: color,
      fillOpacity: 0.9
    });
  }
}
