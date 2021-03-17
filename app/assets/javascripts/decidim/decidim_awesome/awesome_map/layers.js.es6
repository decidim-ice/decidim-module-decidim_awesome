// = require decidim/decidim_awesome/awesome_map/utilities
// = require decidim/decidim_awesome/awesome_map/categories
// = require decidim/decidim_awesome/awesome_map/hashtags

((exports) => {
  const { collapsedMenu, options, getCategory, hashtags, categories } = exports.AwesomeMap;
  const layers = {};
  const cluster = L.markerClusterGroup();

  const control = L.control.layers(null, null, {
    position: 'topleft',
    sortLayers: false,
    collapsed: collapsedMenu,
    // hideSingleBase: true
  });

  const addProposalsControls = (map, component) => {
    // add control layer for proposals
    layers.proposals = {
      label: `<span class="awesome_map-component" id="awesome_map-component_${component.id}" title="0">${component.name || window.DecidimAwesome.texts.proposals}</span>`,
      group: L.featureGroup.subGroup(cluster)
    };
    control.addOverlay(layers.proposals.group, layers.proposals.label);
    layers.proposals.group.addTo(map);

    // add control layer for amendments if any
    if(options.menu.amendments && component.amendments) {
      layers.amendments = {
        label: `<span class="awesome_map-component" id="awesome_map-amendments_${component.id}" title="0">${window.DecidimAwesome.texts.amendments}</span>`,
        group: L.featureGroup.subGroup(cluster)
      }
      control.addOverlay(layers.amendments.group, layers.amendments.label);
      layers.amendments.group.addTo(map);
    }

  };

  const addMeetingsControls = (map, component) => {
    // add control layer for meetings
    layers.meetings = {
      label: `<span class="awesome_map-component" id="awesome_map-component_${component.id}" title="0">${component.name || window.DecidimAwesome.texts.meetings}</span>`,
      group: L.featureGroup.subGroup(cluster)
    };
    control.addOverlay(layers.meetings.group, layers.meetings.label);
    layers.meetings.group.addTo(map);
  };

  const addCategoriesControls = (map) => {
    let lastLayer = layers[Object.keys(layers)[Object.keys(layers).length - 1]];
    // Add Categories "title"
    if(lastLayer) {
      lastLayer.label = `${lastLayer.label}<hr><b>${window.DecidimAwesome.texts.categories}</b>`;
      control.removeLayer(lastLayer.group);
      control.addOverlay(lastLayer.group, lastLayer.label);
    }

    categories.forEach((category) => {
      // add control layer for this category
      layers[category.id] = {
        label: `<i class="awesome_map-category_${category.id}"></i> ${category.name}`,
        group: L.featureGroup.subGroup(cluster)
      };
      layers[category.id].group.addTo(map);
      control.addOverlay(layers[category.id].group, layers[category.id].label);
      // hide layer by default, it will be activated if there's any marker in it
      setTimeout(() => {
        $(`.awesome_map-category_${category.id}`).closest("label").hide();
      });
    });

    // watch events for subcategories sync
    const getCatFromClass = (name) => {
      let id = name.match(/awesome_map-category_(\d+)/)
      if(!id) return;
      const cat = getCategory(id[1]);
      if(!cat || !cat.name) return;

      return cat;
    };

    const indeterminateInput = (id) => {
      $('[class^="awesome_map-category_"]').parent().prev().prop("indeterminate", false);
      if(id) {
        let $input = $(`.awesome_map-category_${id}`).parent().prev();
        if(!$input.prop("checked")) {
          $input.prop("indeterminate", true);
        }
      }
    };

    map.on('overlayadd', (e) => {
      const cat = getCatFromClass(e.name);
      if(!cat) return;
      // if it's a children, put the parent to indeterminate
      indeterminateInput(cat.parent);
    });

    // on remove a parent category, remove all children
    map.on('overlayremove', (e) => {
      const cat = getCatFromClass(e.name);
      if(!cat) return;
      cat.children().forEach((c) => {
        let $el = $(`.awesome_map-category_${c.id}`);
        if($el.parent().prev().prop("checked")) {
          $el.click();
        }
      });
    });
  };

  const addHashtagsControls = (map) => {
    console.log("add hashtags control");
    console.log(hashtags);
  };

  exports.AwesomeMap.layers = layers;
  exports.AwesomeMap.control = control;
  exports.AwesomeMap.cluster = cluster;
  exports.AwesomeMap.addProposalsControls = addProposalsControls;
  exports.AwesomeMap.addMeetingsControls = addMeetingsControls;
  exports.AwesomeMap.addCategoriesControls = addCategoriesControls;
  exports.AwesomeMap.addHashtagsControls = addHashtagsControls;
})(window);
