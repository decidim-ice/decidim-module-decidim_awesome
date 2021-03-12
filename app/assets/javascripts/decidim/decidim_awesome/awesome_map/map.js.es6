// = require jsrender.min
// = require leaflet.featuregroup.subgroup
// = require decidim/decidim_awesome/awesome_map/categories
// = require decidim/decidim_awesome/awesome_map/proposals
// = require decidim/decidim_awesome/awesome_map/meetings
// = require_self

((exports) => {
  const { fetchProposals, fetchMeetings, getCategory } = exports.AwesomeMap;

  const collapsedMenu = $("#awesome-map").data("collapsed");
  const show = {
    withdrawn: $("#awesome-map").data("show-withdrawn"),
    accepted: $("#awesome-map").data("show-accepted"),
    evaluating: $("#awesome-map").data("show-evaluating"),
    notAnswered: $("#awesome-map").data("show-not-answered"),
    rejected: $("#awesome-map").data("show-rejected")
  };
  const components = $("#awesome-map").data("components");
  const popupMeetingTemplateId = "marker-meeting-popup";
  const popupProposalTemplateId = "marker-proposal-popup";

  const cluster = L.markerClusterGroup();
  const amendments = [];

  const layers = {};

  const control = L.control.layers(null, null, {
    position: 'topleft', 
    sortLayers: false,
    collapsed: collapsedMenu, 
    // hideSingleBase: true
  });
  const allMarkers = [];

  const drawMarker = (element, marker, component) => {
    let tmpl = component.type === "proposals" ? popupProposalTemplateId : popupMeetingTemplateId,
        node = document.createElement("div");

    $($.templates(`#${tmpl}`).render(element)).appendTo(node);
    
    marker.bindPopup(node, {
      maxwidth: 640,
      minWidth: 500,
      keepInView: true,
      className: "map-info"
    }).openPopup();
    
    allMarkers.push({
      marker: marker,
      component: component,
      element: element
    });

    // Check if it has amendments, add it to a list
    if(element.amendments && element.amendments.length) {
      element.amendments.forEach((amendment) => {
        amendments.push(amendment.emendation.id);
      });
    }
    // Add to category layer
    let cat = getCategory(element.category);
    if(layers[cat.id]) {
      marker.addTo(layers[cat.id].group);
      // show category if hidden
      const $label = $(`.awesome_map-category_${cat.id}`).closest("label");
      const $parent = $(`.awesome_map-category_${cat.parent}`).closest("label");
      $label.show();
      // update number of items
      $label.attr("title", parseInt($label.attr("title") || 0) + 1);
      // show parent if apply
      $parent.show();
      $parent.attr("title", parseInt($parent.attr("title") || 0) + 1);
      // update component stats
      const $component = $(`#awesome_map-component-${component.id}`);
      $component.attr("title", parseInt($component.attr("title") || 0) + 1);
    }

    return marker;
  };

  const loadElements = (map) => {
    // legends
    control.addTo(map);
    cluster.addTo(map);

    // Load markers
    components.forEach((component) => {  
      if(component.type == "proposals") {
        // add control layer for proposals
        layers.proposals = {
          label: `<span class="awesome_map-component" id="awesome_map-component-${component.id}" title="0">${component.name || window.DecidimAwesome.texts.proposals}</span>`,
          group: L.featureGroup.subGroup(cluster)
        };
        control.addOverlay(layers.proposals.group, layers.proposals.label);
        layers.proposals.group.addTo(map);

        // add control layer for amendments if any
        if(component.amendments) {
          layers.amendments = {
            label: `<span class="awesome_map-component" id="awesome_map-component-${component.d}" title="0">${window.DecidimAwesome.texts.amendments}</span>`,
            group: L.featureGroup.subGroup(cluster)
          }
          control.addOverlay(layers.amendments.group, layers.amendments.label);
          layers.amendments.group.addTo(map);
        }

        fetchProposals(component, '', (element, marker) => {
            console.log(element.state, show[element.state || 'notAnswered'], show, element);
            if(show[element.state || 'notAnswered']) {
              drawMarker(element, marker, component).addTo(layers.proposals.group)   
            }
          }, () => {
            // finall call
            map.fitBounds(cluster.getBounds(), { padding: [50, 50] });
            allMarkers.forEach((item) => {
              // add marker to amendments layers if it's an amendment
              if(amendments.find((a) => a == item.element.id)) {
                item.marker.removeFrom(layers.proposals.group);
                item.marker.addTo(layers.amendments.group);
              }
            });
          });
      }
      
      if(component.type == "meetings") {
        // add control layer for meetings
        layers.meetings = {
          label: `<span class="awesome_map-component" id="awesome_map-component-${component.id}" title="0">${component.name || window.DecidimAwesome.texts.meetings}</span>`,
          group: L.featureGroup.subGroup(cluster)
        };
        control.addOverlay(layers.meetings.group, layers.meetings.label);
        layers.meetings.group.addTo(map);
      
        fetchMeetings(component, '', (element, marker) => {
            drawMarker(element, marker, component).addTo(layers.meetings.group);
          }, () => {
            map.fitBounds(cluster.getBounds(), { padding: [50, 50] });
          });
      }
    });


    // add categories control layers
    if(window.AwesomeMap.categories.length) {
      let lastLayer = layers[Object.keys(layers)[Object.keys(layers).length - 1]];
      // Add Categories "title"
      if(lastLayer) {
        lastLayer.label = `${lastLayer.label}<hr><b>${window.DecidimAwesome.texts.categories}</b>`;
        control.removeLayer(lastLayer.group);
        control.addOverlay(lastLayer.group, lastLayer.label);
      }

      window.AwesomeMap.categories.forEach((category) => {
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

      // watch events for subcategories syncronitzation
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

    }

  };

  $("#map").on("ready.decidim", (ev, map) => {
    loadElements(map);
  });

})(window);
