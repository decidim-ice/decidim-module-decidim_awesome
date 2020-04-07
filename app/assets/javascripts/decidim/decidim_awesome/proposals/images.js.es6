// = require_self

$(() => {
  window.DecidimAwesome = window.DecidimAwesome || {};

  const token = $( 'meta[name="csrf-token"]' ).attr( 'content' );
  const $textarea = $("#proposal_body");
  const t = window.DecidimAwesome.texts["drag_and_drop_image"];

  if(!$textarea.length) return;

  if(window.DecidimAwesome.allow_images_in_proposals) {
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