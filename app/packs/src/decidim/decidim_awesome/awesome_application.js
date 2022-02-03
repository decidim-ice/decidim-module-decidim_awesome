import "src/decidim/decidim_awesome/proposals/images"
import "src/decidim/decidim_awesome/forms/autosave"

import {destroyQuillEditor,createQuillEditor,createMarkdownEditor} from "src/decidim/decidim_awesome/editors/editor"

$(() => {
  if(window.DecidimAwesome.allow_images_in_full_editor || window.DecidimAwesome.allow_images_in_small_editor || window.DecidimAwesome.use_markdown_editor) {
    $(".editor-container").each((_idx, container) => {
    	destroyQuillEditor(container);
      if(window.DecidimAwesome.use_markdown_editor) {
        createMarkdownEditor(container);
      } else {
        createQuillEditor(container);
      }
    });
  }
});