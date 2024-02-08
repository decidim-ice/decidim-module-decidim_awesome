// Custom scripts for awesome
import "src/decidim/decidim_awesome/admin/constraint_form_events"
import "src/decidim/decidim_awesome/admin/auto_edit"
import "src/decidim/decidim_awesome/admin/user_picker"
// import "src/decidim/decidim_awesome/admin/proposal_sortings"
import "src/decidim/decidim_awesome/admin/codemirror"
import "src/decidim/decidim_awesome/admin/check_redirections"
import "src/decidim/decidim_awesome/admin/form_exit_warn"

import "src/decidim/decidim_awesome/proposals/custom_fields"
import "src/decidim/decidim_awesome/admin/custom_fields_builder"

import "src/decidim/decidim_awesome/editors/tabs_focus"

window.DecidimAwesome = window.DecidimAwesome || {};

// import {destroyQuillEditor, createQuillEditor, createMarkdownEditor} from "src/decidim/decidim_awesome/editors/editor"

// $(() => {
//   $(".editor-container").each((_idx, container) => {
//     destroyQuillEditor(container);
//     if (window.DecidimAwesome.use_markdown_editor) {
//       createMarkdownEditor(container);
//     } else {
//       createQuillEditor(container);
//     }
//   });
// });
