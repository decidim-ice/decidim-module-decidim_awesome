// = require decidim/decidim_awesome/awesome_map/layers
// = require decidim/decidim_awesome/awesome_map/utilities
// = require decidim/decidim_awesome/awesome_map/markers
// = require decidim/decidim_awesome/awesome_map/categories
// = require decidim/decidim_awesome/awesome_map/proposals
// = require decidim/decidim_awesome/awesome_map/meetings
// = require_self

((exports) => {
  const {
    layers,
    hideControls,
    cluster,
    control,
    addProposalsControls,
    addMeetingsControls,
    addSearchControls,
    addCategoriesControls,
    addHashtagsControls,
    fetchProposals,
    fetchMeetings,
    options,
    show,
    components,
    amendments,
    allMarkers,
    drawMarker,
    getCategory
  } = exports.AwesomeMap;
  const $ = exports.$; // eslint-disable-line

  exports.AwesomeMap.allMarkersLoaded = $.noop;

  const autoResizeMap = (map) => {
    // Setup center/zoom options if specified, otherwise fitbounds
    if(options().center) {
      map.setView(options().center, options().zoom);
    } else if(cluster.getBounds().isValid()) {
      map.fitBounds(cluster.getBounds(), { padding: [50, 50] });
    }
  };

  exports.AwesomeMap.loadMapElements = (map) => {
    autoResizeMap(map);
    // legends
    control.addTo(map);
    cluster.addTo(map);
    if(hideControls()) {
      $(control.getContainer()).hide()
    }

    // Load markers
    components().forEach((component) => {
      if(component.type == "proposals") {
        addProposalsControls(map, component);

        fetchProposals(component, '', (element, marker) => {
            // console.log(element.state, show[element.state || 'notAnswered'], show, element);
            if(show()[element.state || 'notAnswered']) {
              drawMarker(element, marker, component).addTo(layers.proposals.group);
              // Add hashtags menu items here, only hashtags with proposals associated will be present
              if(options().menu.hashtags) {
                addHashtagsControls(map, element.hashtags, marker);
              }
            }
          }, () => { // final call
            // Setup center/zoom options if specified, otherwise fitbounds
            autoResizeMap(map);

            allMarkers.forEach((item) => {
              // add marker to amendments layers if it's an amendment
              if(amendments.find((a) => a == item.element.id)) {
                item.marker.removeFrom(layers.proposals.group);
                if(options().menu.amendments) {
                  item.marker.addTo(layers.amendments.group);
                }
              }
            });
            // Call a trigger, might be useful for customizations
            exports.AwesomeMap.allMarkersLoaded();
          });
        }

        if(options().menu.meetings && component.type == "meetings") {
          addMeetingsControls(map, component);

          fetchMeetings(component, '', (element, marker) => {
            drawMarker(element, marker, component).addTo(layers.meetings.group);
          }, () => autoResizeMap(map) );
        }
      });

    /*
    * We add all categories and hide those that have no proposals
    * This is done this way to ensure all parent categories are displayed
    * even if the have not proposals associated
    */
    addSearchControls(map);
    addCategoriesControls(map);

    // category events
    $("#awesome-map").on("change", ".awesome_map-categories-selector", (e) => {
      e.preventDefault();
      e.stopPropagation();
      const id = $(e.target).closest("label").data("layer");
      const cat = getCategory(id);
      // console.log("changed, layer", id, "cat", cat, "checked", e.target.checked, e);
      if(cat) {
        const layer = layers[cat.id];
        if(e.target.checked) {
          // show group of markers
          map.addLayer(layer.group);

          // if it's a children, put the parent to indeterminate
          indeterminateInput(cat.parent);
        } else {
          // hide group of markers
          map.removeLayer(layer.group);
          // if it's a children, put the parent to indeterminate
          cat.children().forEach((c) => {
            let $el = $(`.awesome_map-category-${c.id}`);
            if($el.parent().prev().prop("checked")) {
              $el.click();
            }
          });
        }
        // sync tags
        updateHashtagLayers();
      }
    });

    const indeterminateInput = (id) => {
      $('[class^="awesome_map-category-"]').parent().prev().prop("indeterminate", false);
      if(id) {
        let $input = $(`.awesome_map-category-${id}`).parent().prev();
        if(!$input.prop("checked")) {
          $input.prop("indeterminate", true);
        }
      }
    };

    const updateHashtagLayers = () => {
      // hide all
      $(".awesome_map-hashtags-selector").each((_idx, el) => {
        const layer = layers[$(el).closest("label").data("layer")];
        if(layer) {
          map.removeLayer(layer.group);
        }
      });
      // show selected only
      $(".awesome_map-hashtags-selector:checked").each((_idx, el) => {
        const layer = layers[$(el).closest("label").data("layer")];
        if(layer) {
          map.addLayer(layer.group);
        }
      });
      // hide non-selected categories
      $(".awesome_map-categories-selector:not(:checked)").each((_idx, el) => {
        const layer = layers[$(el).closest("label").data("layer")];
        if(layer) {
          map.addLayer(layer.group);
          map.removeLayer(layer.group);
        }
      });
    };

    // hashtag events
    $("#awesome-map").on("change", ".awesome_map-hashtags-selector", (e) => {
      e.preventDefault();
      e.stopPropagation();
      const tag = $(e.target).closest("label").data("layer");
      // console.log("changed, layer", tag, "checked", e.target.checked, e);
      if(tag) {
        updateHashtagLayers();
      }
    });

    // select/deselect all tags
    $("#awesome-map").on("click", ".awesome_map-toggle_all_tags", (e) => {
      e.preventDefault();
      e.stopPropagation();
      $("#awesome-map .awesome_map-hashtags-selector").prop("checked", $("#awesome-map .awesome_map-hashtags-selector:checked").length < $("#awesome-map .awesome_map-hashtags-selector").length);
      updateHashtagLayers();
    });

    // sub-layer hashtag title toggle
    $("#awesome-map").on("click", ".awesome_map-title-control", (e) => {
      e.preventDefault();
      e.stopPropagation();
      $("#awesome_map-hashtags-control").toggleClass("active");
    });
  };

  // order hashtags alphabetically
  exports.AwesomeMap.hashtagAdded = (_hashtag, $div) => {
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
  };
})(window);
