$(function () {
  // Tries to load the map because we cannot be sure if leaflet and decicim maps is loaded yet (other views can initialize snippets or not)
  const waitForMap = ($map) => {
      const map = $map.data("map");
      if(window.AwesomeMap && window.AwesomeMap.loadMapElements && map) {
        window.AwesomeMap.loadMapElements(map);
    } else {
      setTimeout(() => {
        waitForMap($map);
      }, 100);
    }
  };

  waitForMap($("#awesome-map .google-map"));
});
