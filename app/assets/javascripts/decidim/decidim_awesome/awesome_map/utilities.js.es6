//= require jquery.truncate

((exports) => {
  const maxLength = $("#awesome-map").data("truncate");

  const options = {
    length: maxLength || 255
  }

  const truncate = (string) => {
    return $.truncate(string, options);
  };

  exports.AwesomeMap = exports.AwesomeMap || {};
  exports.AwesomeMap.truncate = truncate;
})(window);
