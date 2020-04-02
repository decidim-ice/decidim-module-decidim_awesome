// = require inscrybmde.min.js
// = require jquery.inline-attachment.js
// = require_self

$(() => {
  window.DecidimAwesome = window.DecidimAwesome || {};

  const token = $( 'meta[name="csrf-token"]' ).attr( 'content' );

  // Redefines Quill editor with images
  if(window.DecidimAwesome.use_markdown_in_proposals) {
    const inscrybmde = new InscrybMDE({
      element: $("#proposal_body")[0]
    })
    console.log('init', inscrybmde)
  } else if(window.DecidimAwesome.allow_images_in_proposals) {
     $('textarea').inlineattachment({
        uploadUrl: window.DecidimAwesome.editor_uploader_path,
        uploadFieldName: "image",
        extraHeaders: { 'X-CSRF-Token': token }
    });
  }


});