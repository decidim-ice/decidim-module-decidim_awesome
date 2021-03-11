((exports) => {
  const maxLengthDefault = 255
  const truncate = (string, maxLength) => {
    maxLength = maxLength || maxLengthDefault;
    if (string.length > maxLength) {
      return string.substring(0, maxLength - 3) + "...";
    }
    else {
      return string;
    }
  };

  exports.AwesomeMap = exports.AwesomeMap || {};
  exports.AwesomeMap.truncate = truncate;
})(window);
