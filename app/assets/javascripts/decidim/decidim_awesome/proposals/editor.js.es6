// = require inscrybmde.min.js
// = require_self

$(() => {
  window.DecidimAwesome = window.DecidimAwesome || {};

  // Redefines Quill editor with images
  if(window.DecidimAwesome.use_markdown_in_proposals) {
    const inscrybmde = new InscrybMDE({
      element: $("#proposal_body")[0]
    })
    console.log('init', inscrybmde)
  }

});