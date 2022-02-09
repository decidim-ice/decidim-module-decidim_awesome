import AwesomeMap from "src/decidim/decidim_awesome/awesome_map/awesome_map"

$(() => {
  const sanitizeCenter = (string) => {
    if(string) {
      const parts = string.split(",")
      if (parts.length >= 2) {
        const lat = parseFloat(parts[0]);
        const lng = parseFloat(parts[1]);
        if(lat && lng) {
          return [lat, lng];
        }
      }
    }
  };

  const config = {
    length: $("#awesome-map").data("truncate") || 254,
    center: sanitizeCenter($("#awesome-map").data("map-center")),
    zoom: $("#awesome-map").data("map-zoom"),    
    menu: {
      amendments: $("#awesome-map").data("menu-amendments"),
      meetings: $("#awesome-map").data("menu-meetings"),
      categories: $("#awesome-map").data("menu-categories"),
      hashtags: $("#awesome-map").data("menu-hashtags"),
      mergeComponents: $("#awesome-map").data("menu-merge-components")
    },
    show: {
      withdrawn: $("#awesome-map").data("show-withdrawn"),
      accepted: $("#awesome-map").data("show-accepted"),
      evaluating: $("#awesome-map").data("show-evaluating"),
      notAnswered: $("#awesome-map").data("show-not-answered"),
      rejected: $("#awesome-map").data("show-rejected")
    },
    hideControls: $("#awesome-map").data("hide-controls"),
    collapsedMenu: $("#awesome-map").data("collapsed"),
    components: $("#awesome-map").data("components")
  };

  // build awesome map (if exist)
  $("#awesome-map .google-map").on("ready.decidim", (evt, map) => {
    // bindPopup doesn't work for some unknown cause and these handler neither so we're cancelling them
    map.off("popupopen");
    map.off("popupclose");

    // console.log("ready map", map);

    window.AwesomeMap = new AwesomeMap(map, config);
    window.AwesomeMap.loadControllers();
  });
});
