import "src/decidim/decidim_awesome/proposals/images"
import "src/decidim/decidim_awesome/forms/autosave"

import {destroyQuillEditor,createQuillEditor,createMarkdownEditor} from "src/decidim/decidim_awesome/editors/editor"

$(() => {
  $(".editor-container").each((_idx, container) => {
  	destroyQuillEditor(container);
    if(window.DecidimAwesome.use_markdown_editor) {
      createMarkdownEditor(container);
    } else {
      createQuillEditor(container);
    }
  });
});