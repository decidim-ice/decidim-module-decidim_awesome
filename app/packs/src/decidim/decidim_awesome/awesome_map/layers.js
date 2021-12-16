// TODO
// = require leaflet.featuregroup.subgroup
// TODO
import "src/decidim/decidim_awesome/awesome_map/utilities"
import "src/decidim/decidim_awesome/awesome_map/categories"
import "src/decidim/decidim_awesome/awesome_map/hashtags"

((exports) => {
  const { collapsedMenu, options, categories } = exports.AwesomeMap;
  const layers = {};
  const cluster = L.markerClusterGroup();

  const control = L.control.layers(null, null, {
    position: 'topleft',
    sortLayers: false,
    collapsed: collapsedMenu(),
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
    if(options().menu.amendments && component.amendments) {
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
    // console.log("map",map,"cluster", cluster, "layers", layers, "component", component)
    layers.meetings.group.addTo(map);
  };

  const addSearchControls = () => {
    $(control.getContainer()).contents("form").after(`<div id="awesome_map-categories-control" class="active"><b class="awesome_map-title-control">${window.DecidimAwesome.texts.categories}</b><div class="categories-container"></div></div>
    <div id="awesome_map-hashtags-control"><b class="awesome_map-title-control">${window.DecidimAwesome.texts.hashtags}</b><div class="hashtags-container"></div><a href="#" class="awesome_map-toggle_all_tags">${window.DecidimAwesome.texts.select_deselect_all}</a></div>`);
  };

  const addCategoriesControls = (map) => {
    if(categories && categories.length) {
      categories.forEach((category) => {
        // add control layer for this category
      const label = `<i class="awesome_map-category-${category.id}"></i> ${category.name}`;
      layers[category.id] = {
        label: label,
        group: L.featureGroup.subGroup(cluster)
      };
      layers[category.id].group.addTo(map);
      // In the next iteration to be sure layers are rendered
      setTimeout(() => {
        $('#awesome_map-categories-control .categories-container').append(`<label data-layer="${category.id}" class="awesome_map-category-${category.id}${category.parent?" subcategory":""}"><input type="checkbox" class="awesome_map-categories-selector" checked><span>${label}</span></label>`);
      });
    });
  }
  };

  // Hashtags are collected directly from proposals (this is different than categories)
  const addHashtagsControls = (map, hashtags, marker) => {
     // show hashtag layer
    if(hashtags && hashtags.length) {
      $('#awesome_map-hashtags-control').show();
      hashtags.forEach(hashtag => {
        // Add layer if not exists, otherwise just add the marker to the group
        if(!layers[hashtag.tag]) {
          layers[hashtag.tag] = {
            label: hashtag.name,
            group: L.featureGroup.subGroup(cluster)
          };
          layers[hashtag.tag].group.addTo(map);
          $('#awesome_map-hashtags-control .hashtags-container').append(`<label data-layer="${hashtag.tag}" class="awesome_map-hashtag-${hashtag.tag}"><input type="checkbox" class="awesome_map-hashtags-selector" checked><span>${hashtag.name}</span></label>`);
          // Call a trigger, might be in service for customizations
          exports.AwesomeMap.hashtagAdded(hashtag, $('#awesome_map-hashtags-control .hashtags-container'));
        }
        marker.addTo(layers[hashtag.tag].group);

        const $label = $(`label.awesome_map-hashtag-${hashtag.tag}`);
        // update number of items
        $label.attr("title", (parseInt($label.attr("title") || 0) + 1) + " " +  window.DecidimAwesome.texts.items);
      });
    }
  };

  exports.AwesomeMap.layers = layers;
  exports.AwesomeMap.control = control;
  exports.AwesomeMap.cluster = cluster;
  exports.AwesomeMap.addProposalsControls = addProposalsControls;
  exports.AwesomeMap.addMeetingsControls = addMeetingsControls;
  exports.AwesomeMap.addSearchControls = addSearchControls;
  exports.AwesomeMap.addCategoriesControls = addCategoriesControls;
  exports.AwesomeMap.addHashtagsControls = addHashtagsControls;
  exports.AwesomeMap.hashtagAdded = $.noop;
})(window);
