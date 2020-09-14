class Category {
  constructor(category, color = null) {
    this.id = category.id;
    this.lang = document.querySelector('html').getAttribute('lang');
    this.name = this.findTranslation(category.name.translations);
    this._color = color || "#ef604d";
  }

  get color() {
    return this._color;
  }

  set color(c) {
    this._color = c;
  }

  findTranslation(translations) {
    let text;
    translations.forEach((t) => {
      if(t.text) {
        if(!text || t.locale == this.lang) {
          text = t.text
        }
      }
    });
    return text;
  }
}

class CategoryList {
  constructor() {
    this._list = {}
    this._defaultColor = null;
    this._onRebuild = () => {}
    this._rebuildID = null;
  }

  get list() {
    return Object.entries(this._list);
  }

  set defaultColor(color) {
    this._defaultColor = color;
  }

  set list(category) {
    this._list[category.id] = new Category(category, this._defaultColor);
  }

  set onRebuild(callback) {
    this._onRebuild = callback;
  }

  get(category) {
    if(!this._list[category.id]) {
      this.list = category;
      this.rebuildColors();
    }
    return this._list[category.id];    
  }

  // Rebuild defers execution to the next cycle in case another
  // call tries to rebuild colors. The later call will be executed
  rebuildColors() {
    if(this._rebuildID) {
      clearTimeout(this._rebuildID);
    }
    this._rebuildID = setTimeout(() => {
      let list = this.list;
      list.forEach(([, cat], index) => {
        cat.color = this.rainbow(list.length, index);
      });
      
      this._onRebuild();
    });
  }

  rainbow(numOfSteps, step) {
    // This function generates vibrant, "evenly spaced" colours (i.e. no clustering). This is ideal for creating easily distinguishable vibrant markers in Google Maps and other apps.
    // Adam Cole, 2011-Sept-14
    // HSV to RBG adapted from: http://mjijackson.com/2008/02/rgb-to-hsl-and-rgb-to-hsv-color-model-conversion-algorithms-in-javascript
    var r, g, b;
    var h = step / numOfSteps;
    var i = ~~(h * 6);
    var f = h * 6 - i;
    var q = 1 - f;
    switch(i % 6){
        case 0: r = 1; g = f; b = 0; break;
        case 1: r = q; g = 1; b = 0; break;
        case 2: r = 0; g = 1; b = f; break;
        case 3: r = 0; g = q; b = 1; break;
        case 4: r = f; g = 0; b = 1; break;
        case 5: r = 1; g = 0; b = q; break;
    }
    var c = "#" + ("00" + (~ ~(r * 255)).toString(16)).slice(-2) + ("00" + (~ ~(g * 255)).toString(16)).slice(-2) + ("00" + (~ ~(b * 255)).toString(16)).slice(-2);
    return (c);
  }
}

((exports) => {

  const Categories = new CategoryList;

  Categories.defaultColor = getComputedStyle(document.documentElement).getPropertyValue('--primary');

  exports.AwesomeMap = exports.AwesomeMap || {};
  exports.AwesomeMap.Categories = Categories;
})(window);
