((exports) => {

  const getCategory = (category) => {
    let defaultCat = {
      color: getComputedStyle(document.documentElement).getPropertyValue('--primary')
    };
    console.log("get", category)
    if(category) {
      let id = parseInt(category.id, 10);
      let cat = exports.AwesomeMap.categories.find((c) => c.id == id);
      if(cat) {
        return cat;
      }
    }
    return defaultCat;
  };

  exports.AwesomeMap = exports.AwesomeMap || {};
  exports.AwesomeMap.getCategory = getCategory;
})(window);
