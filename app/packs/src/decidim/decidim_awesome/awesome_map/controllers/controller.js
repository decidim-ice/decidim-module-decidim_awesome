import * as L from "leaflet";

export default class Controller {
  constructor(awesomeMap, component) {
    this.awesomeMap = awesomeMap;
    this.component = component;
    this.templateId = "marker-meeting-popup";
    this.controls = {
      label: `<span class="awesome_map-component" id="awesome_map-component_${component.id}" title="0" data-layer="${component.type}">${component.name || window.DecidimAwesome.texts[component.type]}</span>`,
      group: L.featureGroup.subGroup(this.awesomeMap.cluster)
    };
    this.onFinished = () => {};
    this.allMarkers = [];

  }

  setFetcher(Fetcher) {
    this.fetcher = new Fetcher(this);
    this.fetcher.onFinished = () => {
      // console.log(`all ${this.component.type} loaded`, this)
      this._onFinished();
    };
  }

  getFetcher() {
    this.fetcher;
  }

  addControls() {
    this.awesomeMap.controls.main.addOverlay(this.controls.group, this.controls.label);
    this.controls.group.addTo(this.awesomeMap.map);
  }

  loadNodes() {
    // to override
  }

  addMarker(marker, node) {
    /* theorically, this should be enough to create popups on markers but looks that there is som bug in leaflet that sometimes prevents this to work
    let node = document.createElement("div");
    // console.log("addMarker", marker, "node", node)
    node.innerHTML = $.templates(`#${this.templateId}`).render(node);
    marker.bindPopup(node, {
      maxwidth: 640,
      minWidth: 500,
      keepInView: true,
      className: "map-info"
    }); */

    marker.on("click", () => {
      let dom = document.createElement("div");
      dom.innerHTML = $.templates(`#${this.templateId}`).render(node);

      let pop = L.popup({
        maxwidth: 640,
        minWidth: 500,
        keepInView: true,
        className: "map-info"

      }).setLatLng(marker.getLatLng()).setContent(dom);
      pop.addTo(this.awesomeMap.map);
    });

    marker.addTo(this.controls.group);

    this.allMarkers.push({
      marker: marker,
      component: this.component,
      node: node
    });

    this.addMarkerCategory(marker, node.category);
    this.addMarkerHashtags(marker, node.hashtags);
  }

  addMarkerCategory(marker, category) {
    // Add to category layer
    const cat = this.awesomeMap.getCategory(category);
    if(this.awesomeMap.layers[cat.id]) {
      marker.addTo(this.awesomeMap.layers[cat.id].group);
      this.awesomeMap.controls.showCategory(cat);
    }   
  }

  addMarkerHashtags(marker, hashtags) {
    // Add hashtag layer
    if(this.awesomeMap.config.menu.hashtags) {
      this.awesomeMap.controls.addHashtagsControls(hashtags, marker);
    }
  }

  // Override if needed (call this.onFinished() at the end!)
  _onFinished() {
    this.awesomeMap.controls.updateStats(`component_${this.component.id}`, this.allMarkers.length);
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