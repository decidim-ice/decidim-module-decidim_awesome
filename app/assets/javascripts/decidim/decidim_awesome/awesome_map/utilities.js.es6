//= require jquery.truncate

((exports) => {
  const sanitizeCenter = (string) => {
    const parts = string.split(",")
    if (parts.length >= 2) {
      const lat = parseFloat(parts[0]);
      const lng = parseFloat(parts[1]);
      if(lat && lng) {
        return [lat, lng];
      }
    }
    return null
  };

  const options = {
    length: $("#awesome-map").data("truncate") || 255,
    center: sanitizeCenter($("#awesome-map").data("map-center")),
    zoom: $("#awesome-map").data("map-zoom"),
    menu: {
      amendments: $("#awesome-map").data("menu-amendments"),
      meetings: $("#awesome-map").data("menu-meetings"),
      hashtags: $("#awesome-map").data("menu-hashtags")
    }
  };

  const truncate = (string) => {
    return $.truncate(string, options);
  };

  const show = {
    withdrawn: $("#awesome-map").data("show-withdrawn"),
    accepted: $("#awesome-map").data("show-accepted"),
    evaluating: $("#awesome-map").data("show-evaluating"),
    notAnswered: $("#awesome-map").data("show-not-answered"),
    rejected: $("#awesome-map").data("show-rejected")
  };

  const collapsedMenu = $("#awesome-map").data("collapsed");
  const components = $("#awesome-map").data("components");

  exports.AwesomeMap = exports.AwesomeMap || {};
  exports.AwesomeMap.truncate = truncate;
  exports.AwesomeMap.options = options;
  exports.AwesomeMap.show = show;
  exports.AwesomeMap.collapsedMenu = collapsedMenu;
  exports.AwesomeMap.components = components;
})(window);
