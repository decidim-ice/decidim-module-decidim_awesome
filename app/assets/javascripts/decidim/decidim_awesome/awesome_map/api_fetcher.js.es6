class ApiFetcher {

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
}
