/* eslint-disable no-ternary, multiline-ternary, no-nested-ternary, max-lines */

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
      this.removeHiddenTaxonomies();
    });
  }

  attach() {
    // legends
    this.main.addTo(this.awesomeMap.map);

    this.addSearchControls();
    if (this.awesomeMap.config.menu.taxonomies) {
      this.addTaxonomiesControls();
    }

    // sub-layer hashtag title toggle
    $("#awesome-map").on("click", ".awesome_map-title-control", (evt) => {
      evt.preventDefault();
      evt.stopPropagation();
      const taxonomies = document.getElementById("awesome_map-taxonomies-control");
      const hashtags = document.getElementById("awesome_map-hashtags-control");
      if (taxonomies) {
        taxonomies.classList.toggle("active");
      }
      if (hashtags) {
        hashtags.classList.toggle("active");
      }
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

    this.awesomeMap.map.on("popupopen", () => {
      // console.log("popup open");
      // hide Controls
      document.querySelector(".leaflet-control-layers.leaflet-control").style.display = "none";
    });
    this.awesomeMap.map.on("popupclose", () => {
      // console.log("popup close");
      // restore controls
      document.querySelector(".leaflet-control-layers.leaflet-control").style.display = "block";
    });
  }

  addSearchControls() {
    const section = this.main.getContainer().querySelector(".leaflet-control-layers-list");
    if (section) {
      section.insertAdjacentHTML("beforeend", `<div id="awesome_map-taxonomies-control" class="active"><b class="awesome_map-title-control">${window.DecidimAwesome.i18n.taxonomies}</b><div class="taxonomies-container"></div></div>
    <div id="awesome_map-hashtags-control"><b class="awesome_map-title-control">${window.DecidimAwesome.i18n.hashtags}</b><div class="hashtags-container"></div><a href="#" class="awesome_map-toggle_all_tags">${window.DecidimAwesome.i18n.selectDeselectAll}</a></div>`);
    } else {
      console.error("Can't find the section to insert the controls");
    }
  }

  addTaxonomiesControls() {
    // First, organize taxonomies by levels
    const rootTaxonomies = this.awesomeMap.taxonomies.filter((tax) => !tax.parent);

    // Process each root taxonomy independently
    rootTaxonomies.forEach((rootTaxonomy) => {
      // Add the root taxonomy
      this._addTaxonomyToUI(rootTaxonomy, 0);

      // Find and add direct children of this root taxonomy
      const children = this.awesomeMap.taxonomies.filter((tax) => tax.parent === rootTaxonomy.id);

      children.forEach((child) => {
        this._addTaxonomyToUI(child, 1);

        // Find and add grandchildren of this child
        const grandchildren = this.awesomeMap.taxonomies.filter((tax) => tax.parent === child.id);

        grandchildren.forEach((grandchild) => {
          this._addTaxonomyToUI(grandchild, 2);
        });
      });
    });

    // taxonomy events
    $("#awesome-map").on("change", ".awesome_map-taxonomies-selector", (evt) => {
      evt.preventDefault();
      evt.stopPropagation();

      const id = $(evt.target).closest("label").data("layer");
      const taxonomy = this.awesomeMap.getTaxonomy(id);

      if (taxonomy) {
        this._handleTaxonomyToggle(taxonomy, evt.target.checked);
      }
    });
  }

  _addTaxonomyToUI(taxonomy, level) {
    // Create control layer for this taxonomy
    const circleIcon = taxonomy.parent ? `<i class="awesome_map-taxonomy_${taxonomy.id}"></i> ` : "";
    const label = `${circleIcon}${taxonomy.name}`;
    this.awesomeMap.layers[taxonomy.id] = {
      label: label,
      group: new L.FeatureGroup.SubGroup(this.awesomeMap.cluster)
    };
    this.awesomeMap.layers[taxonomy.id].group.addTo(this.awesomeMap.map);

    const taxonomiesContainer = document.querySelector("#awesome_map-taxonomies-control .taxonomies-container");
    if (taxonomiesContainer) {
      const levelClass = level === 0 ? "root-taxonomy" : level === 1 ? "child-taxonomy" : "grandchild-taxonomy";
      const indentStyle = `style="padding-left: ${level * 20}px;"`;

      taxonomiesContainer.insertAdjacentHTML("beforeend",
        `<label data-layer="${taxonomy.id}"
                class="awesome_map-taxonomy-${taxonomy.id} ${levelClass}"
                data-parent="${taxonomy.parent || ""}"
                data-level="${level}"
                ${indentStyle}>
          <input type="checkbox" class="awesome_map-taxonomies-selector" checked>
          <span>${label}</span>
        </label>`
      );
    } else {
      console.error("Can't find the section to insert the taxonomies");
    }
  }

  _handleTaxonomyToggle(taxonomy, isChecked) {
    const layer = this.awesomeMap.layers[taxonomy.id];

    if (isChecked) {
      // Show group of markers
      this.awesomeMap.map.addLayer(layer.group);
    } else {
      // Hide group of markers
      this.awesomeMap.map.removeLayer(layer.group);
      // Uncheck all children when parent is unchecked
      this._uncheckChildrenTaxonomies(taxonomy.id);
    }

    // Update parent state (indeterminate/checked/unchecked)
    this._updateParentTaxonomyState(taxonomy);

    // sync hashtags
    this.updateHashtagLayers();
  }

  _uncheckChildrenTaxonomies(taxonomyId) {
    const children = this.awesomeMap.taxonomies.filter((tax) => tax.parent === taxonomyId);
    children.forEach((child) => {
      const childInput = document.querySelector(`label[data-layer="${child.id}"] input`);
      if (childInput && childInput.checked) {
        childInput.checked = false;
        this.awesomeMap.map.removeLayer(this.awesomeMap.layers[child.id].group);
        // Recursively uncheck grandchildren
        this._uncheckChildrenTaxonomies(child.id);
      }
    });
  }

  _updateParentTaxonomyState(taxonomy) {
    if (taxonomy.parent) {
      const parentInput = document.querySelector(`label[data-layer="${taxonomy.parent}"] input`);
      if (parentInput) {
        const siblings = this.awesomeMap.taxonomies.filter((tax) => tax.parent === taxonomy.parent);
        const checkedSiblings = siblings.filter((sibling) => {
          const siblingInput = document.querySelector(`label[data-layer="${sibling.id}"] input`);
          return siblingInput && siblingInput.checked;
        });

        if (checkedSiblings.length === 0) {
          // No siblings checked - uncheck parent
          parentInput.checked = true;
          this.awesomeMap.map.removeLayer(this.awesomeMap.layers[taxonomy].group);
        } else if (checkedSiblings.length === siblings.length) {
          // All siblings checked - check parent
          parentInput.checked = true;
          this.awesomeMap.map.addLayer(this.awesomeMap.layers[taxonomy.parent].group);
        } else {
          // Some siblings checked
          parentInput.checked = true;
          this.awesomeMap.map.addLayer(this.awesomeMap.layers[taxonomy.parent].group);
        }

        // Recursively update grandparent
        const parentTaxonomy = this.awesomeMap.getTaxonomy(taxonomy.parent);
        this._updateParentTaxonomyState(parentTaxonomy);
      }
    }
  }

  // Hashtags are collected directly from proposals (this is different than taxonomies)
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
        label.setAttribute("title", `${parseInt(label.title || 0, 10) + 1} ${window.DecidimAwesome.i18n.items}`);
      });
    }
  }

  showTaxonomy(tax) {
    document.getElementById("awesome_map-taxonomies-control").style.display = "block";

    // Show taxonomy if hidden
    const label = document.querySelector(`label.awesome_map-taxonomy-${tax.id}`);
    if (label) {
      label.style.display = "block";
      // update number of items
      const currentCount = parseInt(label.title || 0, 10) + 1;
      label.setAttribute("title", `${currentCount} ${window.DecidimAwesome.i18n.items}`);
    }

    // Also show all parent taxonomies up the hierarchy
    if (tax.parent) {
      const parentTaxonomy = this.awesomeMap.getTaxonomy(tax.parent);
      if (parentTaxonomy) {
        this.showTaxonomy(parentTaxonomy);
      }
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

  removeHiddenTaxonomies() {
    $(".awesome_map-taxonomies-selector:not(:checked)").each((_idx, el) => {
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
    // hide non-selected taxonomies
    this.removeHiddenComponents();
    this.removeHiddenTaxonomies();
  }

  updateStats(uid, total) {
    // update component stats
    const $component = $(`#awesome_map-${uid}`);
    $component.attr("title", `${total} ${window.DecidimAwesome.i18n.items}`);
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
