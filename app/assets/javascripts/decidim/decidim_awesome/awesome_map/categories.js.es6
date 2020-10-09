((exports) => {

  const getCategory = (category) => {
    let defaultCat = {
      color: getComputedStyle(document.documentElement).getPropertyValue('--primary'),
      children: () => {},
      parent: null,
      name: null
    };
    if(category) {
      let id = category.id ? parseInt(category.id, 10) : parseInt(category, 10);
      let cat = exports.AwesomeMap.categories.find((c) => c.id == id);
      if(cat) {
        cat.children = () => {
          return exports.AwesomeMap.categories.filter((c) => c.parent === cat.id );
        }
        return cat;
      }
    }
    return defaultCat;
  };

  exports.AwesomeMap = exports.AwesomeMap || {};
  exports.AwesomeMap.getCategory = getCategory;
})(window);
