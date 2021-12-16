class ApiFetcher { // eslint-disable-line no-unused-vars

  constructor(query, variables) {
    this.query = query;
    this.variables = variables;
  }

  fetch(callback) {
    $.ajax({
      method: "POST",
      url: "/api",
      contentType: "application/json",
      data: JSON.stringify({
        query: this.query,
        variables: this.variables
      })
    }).done(function(data) {
      callback(data.data);
    });
  }

  fetchAll (callback) {
    this.fetch(callback);
  }

  static findTranslation(translations) {
    let text, lang = document.querySelector('html').getAttribute('lang');
    
    translations.forEach((t) => {
      if(t.text) {
        if(!text || t.locale == lang) {
          text = t.text
        }
      }
    });
    return text;
  }
}
