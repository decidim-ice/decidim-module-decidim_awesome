import * as L from "leaflet";

export default class ControlsUI {
  constructor(awesomeMap) {
    this.awesomeMap = awesomeMap;

    this.main = L.control.layers(null, null, {
      position: 'topleft',
      sortLayers: false,
      collapsed: this.awesomeMap.config.collapsedMenu,
      // hideSingleBase: true
    });

    if(this.awesomeMap.config.hideControls) {
      $(this.main.getContainer()).hide();
    }

    this.$loading = $("#awesome-map .loading-spinner");
    this.onHashtag = this._orderHashtags;

    this.awesomeMap.map.on("overlayadd",() => {
      this.removeHiddenCategories();
    });
  }

  attach() {
    // legends
    this.main.addTo(this.awesomeMap.map);

    this.addSearchControls();
    if(this.awesomeMap.config.menu.categories) {
      this.addCategoriesControls();
    }

    // sub-layer hashtag title toggle
    $("#awesome-map").on("click", ".awesome_map-title-control", (e) => {
      e.preventDefault();
      e.stopPropagation();
      $("#awesome_map-categories-control").toggleClass("active");
      $("#awesome_map-hashtags-control").toggleClass("active");
    });

    // hashtag events
    $("#awesome-map").on("change", ".awesome_map-hashtags-selector", (e) => {
      e.preventDefault();
      e.stopPropagation();
      const tag = $(e.target).closest("label").data("layer");
      // console.log("changed, layer", tag, "checked", e.target.checked, e);
      if(tag) {
        this.updateHashtagLayers();
      }
    });

    // select/deselect all tags
    $("#awesome-map").on("click", ".awesome_map-toggle_all_tags", (e) => {
      e.preventDefault();
      e.stopPropagation();
      $("#awesome-map .awesome_map-hashtags-selector").prop("checked", $("#awesome-map .awesome_map-hashtags-selector:checked").length < $("#awesome-map .awesome_map-hashtags-selector").length);
      this.updateHashtagLayers();
    });
  }

  addSearchControls() {
    $(this.main.getContainer()).contents("form").append(`<div id="awesome_map-categories-control" class="active"><b class="awesome_map-title-control">${window.DecidimAwesome.texts.categories}</b><div class="categories-container"></div></div>
    <div id="awesome_map-hashtags-control"><b class="awesome_map-title-control">${window.DecidimAwesome.texts.hashtags}</b><div class="hashtags-container"></div><a href="#" class="awesome_map-toggle_all_tags">${window.DecidimAwesome.texts.select_deselect_all}</a></div>`);
  }

  addCategoriesControls() {
    this.awesomeMap.categories.forEach((category) => {
      // add control layer for this category
      const label = `<i class="awesome_map-category_${category.id}"></i> ${category.name}`;
      this.awesomeMap.layers[category.id] = {
        label: label,
        group: L.featureGroup.subGroup(this.awesomeMap.cluster)
      };
      this.awesomeMap.layers[category.id].group.addTo(this.awesomeMap.map);
      $('#awesome_map-categories-control .categories-container').append(`<label data-layer="${category.id}" class="awesome_map-category-${category.id}${category.parent?" subcategory":""}" data-parent="${category.parent}"><input type="checkbox" class="awesome_map-categories-selector" checked><span>${label}</span></label>`);
    })

    // category events
    $("#awesome-map").on("change", ".awesome_map-categories-selector", (e) => {
      e.preventDefault();
      e.stopPropagation();

      const id = $(e.target).closest("label").data("layer");
      const cat = this.awesomeMap.getCategory(id);
      // console.log("changed, layer", id, "cat", cat, "checked", e.target.checked, e);
      if(cat) {
        const layer = this.awesomeMap.layers[cat.id];
        if(e.target.checked) {
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
    if(hashtags && hashtags.length) {
      $('#awesome_map-hashtags-control').show();
      hashtags.forEach(hashtag => {
        // Add layer if not exists, otherwise just add the marker to the group
        if(!this.awesomeMap.layers[hashtag.tag]) {
          this.awesomeMap.layers[hashtag.tag] = {
            label: hashtag.name,
            group: new L.FeatureGroup.SubGroup(this.awesomeMap.cluster)
          };
          this.awesomeMap.layers[hashtag.tag].group.addTo(this.awesomeMap.map);
          $('#awesome_map-hashtags-control .hashtags-container').append(`<label data-layer="${hashtag.tag}" class="awesome_map-hashtag-${hashtag.tag}"><input type="checkbox" class="awesome_map-hashtags-selector" checked><span>${hashtag.name}</span></label>`);
          // Call a trigger, might be in service for customizations
          this.onHashtag(hashtag, $('#awesome_map-hashtags-control .hashtags-container'));
        }
        marker.addTo(this.awesomeMap.layers[hashtag.tag].group);

        const $label = $(`label.awesome_map-hashtag-${hashtag.tag}`);
        // update number of items
        $label.attr("title", (parseInt($label.attr("title") || 0) + 1) + " " +  window.DecidimAwesome.texts.items);
      });
    }
  }

  showCategory(cat) {
    $('#awesome_map-categories-control').show();
    // show category if hidden
    const $label = $(`label.awesome_map-category-${cat.id}`);
    const $parent = $(`label.awesome_map-category-${cat.parent}`);
    $label.show();
    // update number of items
    $label.attr("title", (parseInt($label.attr("title") || 0) + 1) + " " +  window.DecidimAwesome.texts.items);
    // show parent if apply
    $parent.show();
    $parent.attr("title", (parseInt($parent.attr("title") || 0) + 1) + " " +  window.DecidimAwesome.texts.items);
  }

  removeHiddenComponents() {
    $(".awesome_map-component").each((_idx, el) => {
      const layer = this.awesomeMap.layers[$(el).data("layer")];
      const $input = $(el).closest("div").find("input:not(:checked)");
      if(layer && $input.length) {
        this.awesomeMap.map.addLayer(layer.group);
        this.awesomeMap.map.removeLayer(layer.group);
      }
    });
  }

  removeHiddenCategories() {
    $(".awesome_map-categories-selector:not(:checked)").each((_idx, el) => {
      const layer = this.awesomeMap.layers[$(el).closest("label").data("layer")];
      if(layer) {
        this.awesomeMap.map.addLayer(layer.group);
        this.awesomeMap.map.removeLayer(layer.group);
      }
    });
  }

  updateHashtagLayers() {
    // hide all
    $(".awesome_map-hashtags-selector").each((_idx, el) => {
      const layer = this.awesomeMap.layers[$(el).closest("label").data("layer")];
      if(layer) {
        this.awesomeMap.map.removeLayer(layer.group);
      }
    });
    // show selected only
    $(".awesome_map-hashtags-selector:checked").each((_idx, el) => {
      const layer = this.awesomeMap.layers[$(el).closest("label").data("layer")];
      if(layer) {
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
    $component.attr("title", `${total} ` + window.DecidimAwesome.texts.items);
  }

  _indeterminateParentInput(cat) {
    if(cat.parent) {
      let $input = $(`.awesome_map-category-${cat.parent}`).contents("input");
      let $subcats = $(`[class^="awesome_map-category-"][data-parent="${cat.parent}"]:visible`);
      let num_checked = $subcats.contents("input:checked").length;
      $input.prop("indeterminate", num_checked != $subcats.length && num_checked != 0);
    }
  }

  // order hashtags alphabetically
  _orderHashtags(_hashtag, $div) {
    let $last = $div.contents("label:last");
    if($last.prev("label").length) {
      // move the label to order it alphabetically
      $div.contents("label").each((_idx, el) => {
        if($(el).text().localeCompare($last.text()) > 0) {
          $(el).before($last);
          return false;
        }
      });
    }
  }
}