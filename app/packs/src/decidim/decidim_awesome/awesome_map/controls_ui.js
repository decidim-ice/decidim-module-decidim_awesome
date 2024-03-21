/* eslint-disable no-ternary, multiline-ternary */

import * as L from "leaflet";

export default class ControlsUI {
  constructor(awesomeMap) {
    this.awesomeMap = awesomeMap;

    this.main = L.control.layers(null, null, {
      position: "topleft",
      sortLayers: false,
      collapsed: this.awesomeMap.config.collapsedMenu
      // hideSingleBase: true
    });

    if (this.awesomeMap.config.hideControls) {
      this.main.getContainer().style.display = "none";
    }

    this.loading = document.querySelector("#awesome-map .loading-spinner");
    this.onHashtag = this._orderHashtags;

    this.awesomeMap.map.on("overlayadd", () => {
      this.removeHiddenCategories();
    });
  }

  attach() {
    // legends
    this.main.addTo(this.awesomeMap.map);

    this.addSearchControls();
    if (this.awesomeMap.config.menu.categories) {
      this.addCategoriesControls();
    }

    // sub-layer hashtag title toggle
    $("#awesome-map").on("click", ".awesome_map-title-control", (evt) => {
      evt.preventDefault();
      evt.stopPropagation();
      $("#awesome_map-categories-control").toggleClass("active");
      $("#awesome_map-hashtags-control").toggleClass("active");
    });

    // hashtag events
    $("#awesome-map").on("change", ".awesome_map-hashtags-selector", (evt) => {
      evt.preventDefault();
      evt.stopPropagation();
      const tag = $(evt.target).closest("label").data("layer");
      // console.log("changed, layer", tag, "checked", evt.target.checked, e);
      if (tag) {
        this.updateHashtagLayers();
      }
    });

    // select/deselect all tags
    $("#awesome-map").on("click", ".awesome_map-toggle_all_tags", (evt) => {
      evt.preventDefault();
      evt.stopPropagation();
      $("#awesome-map .awesome_map-hashtags-selector").prop("checked", $("#awesome-map .awesome_map-hashtags-selector:checked").length < $("#awesome-map .awesome_map-hashtags-selector").length);
      this.updateHashtagLayers();
    });
  }

  addSearchControls() {
    this.main.getContainer().querySelector("form").insertAdjacentHTML("beforeend", `<div id="awesome_map-categories-control" class="active"><b class="awesome_map-title-control">${window.DecidimAwesome.texts.categories}</b><div class="categories-container"></div></div>
    <div id="awesome_map-hashtags-control"><b class="awesome_map-title-control">${window.DecidimAwesome.texts.hashtags}</b><div class="hashtags-container"></div><a href="#" class="awesome_map-toggle_all_tags">${window.DecidimAwesome.texts.select_deselect_all}</a></div>`);
  }

  addCategoriesControls() {
    this.awesomeMap.categories.forEach((category) => {
      // add control layer for this category
      const label = `<i class="awesome_map-category_${category.id}"></i> ${category.name}`;
      this.awesomeMap.layers[category.id] = {
        label: label,
        group: new L.FeatureGroup.SubGroup(this.awesomeMap.cluster)
      };
      this.awesomeMap.layers[category.id].group.addTo(this.awesomeMap.map);
      document.querySelector("#awesome_map-categories-control .categories-container").insertAdjacentHTML("beforeend", `<label data-layer="${category.id}" class="awesome_map-category-${category.id}${category.parent ? " subcategory" : ""}" data-parent="${category.parent}"><input type="checkbox" class="awesome_map-categories-selector" checked><span>${label}</span></label>`);
    })

    // category events
    $("#awesome-map").on("change", ".awesome_map-categories-selector", (evt) => {
      evt.preventDefault();
      evt.stopPropagation();

      const id = $(evt.target).closest("label").data("layer");
      const cat = this.awesomeMap.getCategory(id);
      // console.log("changed, layer", id, "cat", cat, "checked", evt.target.checked, e);
      if (cat) {
        const layer = this.awesomeMap.layers[cat.id];
        if (evt.target.checked) {
          // show group of markers
          this.awesomeMap.map.addLayer(layer.group);
        } else {
          // hide group of markers
          this.awesomeMap.map.removeLayer(layer.group);
          // cat.children().forEach((c) => {
          //   let $el = $(`.awesome_map-category-${c.id}`);
          //   if($el.contents("input").prop("checked")) {
          //     $el.click();
          //   }
          // });
        }
        // if it's a children, put the parent to indeterminate
        this._indeterminateParentInput(cat);
        // sync tags
        this.updateHashtagLayers();
      }
    });
  }

  // Hashtags are collected directly from proposals (this is different than categories)
  addHashtagsControls(hashtags, marker) {
    // show hashtag layer
    if (hashtags && hashtags.length) {
      document.getElementById("awesome_map-hashtags-control").style.display = "block";
      hashtags.forEach((hashtag) => {
        // Add layer if not exists, otherwise just add the marker to the group
        if (!this.awesomeMap.layers[hashtag.tag]) {
          this.awesomeMap.layers[hashtag.tag] = {
            label: hashtag.name,
            group: new L.FeatureGroup.SubGroup(this.awesomeMap.cluster)
          };
          this.awesomeMap.map.addLayer(this.awesomeMap.layers[hashtag.tag].group);
          document.querySelector("#awesome_map-hashtags-control .hashtags-container").insertAdjacentHTML("beforeend", `<label data-layer="${hashtag.tag}" class="awesome_map-hashtag-${hashtag.tag}"><input type="checkbox" class="awesome_map-hashtags-selector" checked><span>${hashtag.name}</span></label>`);
          // Call a trigger, might be in service for customizations
          this.onHashtag(hashtag, $("#awesome_map-hashtags-control .hashtags-container"));
        }
        this.awesomeMap.layers[hashtag.tag].group.addLayer(marker);

        const label = document.querySelector(`label.awesome_map-hashtag-${hashtag.tag}`);
        // update number of items
        label.setAttribute("title", `${parseInt(label.title || 0, 10) + 1} ${window.DecidimAwesome.texts.items}`);
      });
    }
  }

  showCategory(cat) {
    document.getElementById("awesome_map-categories-control").style.display = "block";
    // show category if hidden
    const label = document.querySelector(`label.awesome_map-category-${cat.id}`);
    const parent = document.querySelector(`label.awesome_map-category-${cat.parent}`);
    if (label) {      
      label.style.display = "block";
      // update number of items
      label.setAttribute("title", `${parseInt(label.title || 0, 10) + 1} ${window.DecidimAwesome.texts.items}`);
    }
    if (parent) {
      // show parent if apply
      parent.style.display = "block"
      parent.setAttribute("title", `${parseInt(parent.title || 0, 10) + 1} ${window.DecidimAwesome.texts.items}`);
    }
  }

  removeHiddenComponents() {
    $(".awesome_map-component").each((_idx, el) => {
      const layer = this.awesomeMap.layers[$(el).data("layer")];
      const $input = $(el).closest("div").find("input:not(:checked)");
      if (layer && $input.length) {
        this.awesomeMap.map.addLayer(layer.group);
        this.awesomeMap.map.removeLayer(layer.group);
      }
    });
  }

  removeHiddenCategories() {
    $(".awesome_map-categories-selector:not(:checked)").each((_idx, el) => {
      const layer = this.awesomeMap.layers[$(el).closest("label").data("layer")];
      if (layer) {
        this.awesomeMap.map.addLayer(layer.group);
        this.awesomeMap.map.removeLayer(layer.group);
      }
    });
  }

  updateHashtagLayers() {
    // hide all
    $(".awesome_map-hashtags-selector").each((_idx, el) => {
      const layer = this.awesomeMap.layers[$(el).closest("label").data("layer")];
      if (layer) {
        this.awesomeMap.map.removeLayer(layer.group);
      }
    });
    // show selected only
    $(".awesome_map-hashtags-selector:checked").each((_idx, el) => {
      const layer = this.awesomeMap.layers[$(el).closest("label").data("layer")];
      if (layer) {
        this.awesomeMap.map.addLayer(layer.group);
      }
    });
    // hide non-selected categories
    this.removeHiddenComponents();
    this.removeHiddenCategories();
  }

  updateStats(uid, total) {
    // update component stats
    const $component = $(`#awesome_map-${uid}`);
    $component.attr("title", `${total} ${window.DecidimAwesome.texts.items}`);
  }

  _indeterminateParentInput(cat) {
    if (cat.parent) {
      let $input = $(`.awesome_map-category-${cat.parent}`).contents("input");
      let $subcats = $(`[class^="awesome_map-category-"][data-parent="${cat.parent}"]:visible`);
      let numChecked = $subcats.contents("input:checked").length;
      $input.prop("indeterminate", numChecked !== $subcats.length && numChecked !== 0);
    }
  }

  // order hashtags alphabetically
  _orderHashtags(_hashtag, $div) {
    let $last = $div.contents("label:last");
    if ($last.prev("label").length) {
      // move the label to order it alphabetically
      $div.contents("label").each((_idx, el) => {
        if ($(el).text().localeCompare($last.text()) > 0) {
          $(el).before($last);
        }
      });
    }
  }
}
