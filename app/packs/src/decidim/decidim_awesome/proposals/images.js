import { attach } from "inline-attacher";

document.addEventListener("DOMContentLoaded", () => {
  window.DecidimAwesome = window.DecidimAwesome || {};

  const token = document.querySelector('meta[name="csrf-token"]') && document.querySelector('meta[name="csrf-token"]').getAttribute("content");
  const textarea = document.querySelector("textarea#proposal_body");

  if (!textarea) {
    return;
  }

  if (window.DecidimAwesome.allow_images_in_proposals) {
    // Add the capability to upload images only (they will be presented as links)

    const span = document.createElement("span");
    span.className = "input-character-counter__text";
    span.innerHTML = window.DecidimAwesome.i18n.dragAndDropImage;
    textarea.parentNode.appendChild(span);
    attach(textarea, {
      uploadUrl: window.DecidimAwesome.editorUploaderPath,
      uploadFieldName: "image",
      responseUrlKey: "url",
      progressText: "[Uploading file...]",
      urlText: (url, response) =>  {
        return response.url;
      },
      extraHeaders: { "X-CSRF-Token": token }
    });
  }
});
