import AwesomeMap from "src/decidim/decidim_awesome/awesome_map/awesome_map"

document.addEventListener("DOMContentLoaded", () => {
  const sanitizeCenter = (string) => {
    if (string) {
      const parts = string.split(",")
      if (parts.length >= 2) {
        const lat = parseFloat(parts[0]);
        const lng = parseFloat(parts[1]);
        if (lat && lng) {
          return [lat, lng];
        }
      }
    }
    return null;
  };

  const parse = (string) => {
    if (!string) {
      return null;
    }
    return JSON.parse(string);
  }

  const dataset = document.getElementById("awesome-map").dataset;
  const config = {
    length: parse(dataset.truncate) || 254,
    center: sanitizeCenter(dataset.mapCenter),
    zoom: parse(dataset.mapZoom),    
    menu: {
      amendments: parse(dataset.menuAmendments),
      meetings: parse(dataset.menuMeetings),
      categories: parse(dataset.menuCategories),
      hashtags: parse(dataset.menuHashtags),
      mergeComponents: parse(dataset.menuMergeComponents)
    },
    show: {
      withdrawn: parse(dataset.showWithdrawn),
      accepted: parse(dataset.showAccepted),
      evaluating: parse(dataset.showEvaluating),
      notAnswered: parse(dataset.showNotAnswered),
      rejected: parse(dataset.showRejected)
    },
    hideControls: parse(dataset.hideCcontrols),
    collapsedMenu: parse(dataset.collapsed),
    components: parse(dataset.components)
  };

  // build awesome map (if exist)
  // This event is still launched using JQuery in version 0.28
  $("#awesome-map .dynamic-map").on("ready.decidim", (evt, map) => {
    // bindPopup doesn't work for some unknown cause and these handler neither so we're cancelling them
    map.off("popupopen");
    map.off("popupclose");

    // console.log("ready map", map);

    window.AwesomeMap = new AwesomeMap(map, config);
    window.AwesomeMap.loadControllers();
  });
});
