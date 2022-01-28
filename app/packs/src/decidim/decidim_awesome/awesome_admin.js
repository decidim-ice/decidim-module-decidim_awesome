// Webpack seems to "forgget" about certain libraries already being loaded 
// if javascript_pack_tag is called two times, let's include the whole admin here instead
import "entrypoints/decidim_admin"
import "src/decidim/decidim_awesome/admin/constraints"
import "src/decidim/decidim_awesome/admin/auto_edit"
import "src/decidim/decidim_awesome/admin/user_picker"
import "src/decidim/decidim_awesome/editors/quill_editor"
import "src/decidim/decidim_awesome/admin/form_builder"
import "src/decidim/decidim_awesome/editors/tabs_focus"
import "src/decidim/decidim_awesome/admin/codemirror"
