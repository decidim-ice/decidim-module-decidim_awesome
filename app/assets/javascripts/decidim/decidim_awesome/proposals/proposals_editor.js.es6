// = require highlight.min.js
// = require inscrybmde.min.js
// = require inline-attachment.js
// = require codemirror-4.inline-attachment.js
// = require jquery.inline-attachment.js
// = require_self

$(() => {
  window.DecidimAwesome = window.DecidimAwesome || {};

  const token = $( 'meta[name="csrf-token"]' ).attr( 'content' );
  const $textarea = $("#proposal_body");
  const t = window.DecidimAwesome.texts["drag_and_drop_image"];

  // Redefines Quill editor with images
  if(window.DecidimAwesome.use_markdown_in_proposals) {
    const inscrybmde = new InscrybMDE({
      element: $textarea[0],
      spellChecker: false,
      renderingConfig: {
        codeSyntaxHighlighting: true
      }
    });

    if(window.DecidimAwesome.allow_images_in_proposals) {
      inlineAttachment.editors.codemirror4.attach(inscrybmde.codemirror, {
        uploadUrl: window.DecidimAwesome.editor_uploader_path,
        uploadFieldName: "image",
        jsonFieldName: "url",
        extraHeaders: { "X-CSRF-Token": token }
      });
    }

  } else if(window.DecidimAwesome.allow_images_in_proposals) {
    // Add the capability to upload images only (they will be presented as links)

    $textarea.after(`<p class="help-text">${t}</p>`);
    $textarea.inlineattachment({
        uploadUrl: window.DecidimAwesome.editor_uploader_path,
        uploadFieldName: "image",
        jsonFieldName: "url",
        progressText: "[Uploading file...]",
        urlText: "{filename}",
        extraHeaders: { "X-CSRF-Token": token }
    });
  }
});