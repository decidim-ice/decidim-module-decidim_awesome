import createEditor from "src/decidim/decidim_awesome/editor";
import DecidimKit from "src/decidim/editor/extensions/decidim_kit";

// CSS
import "stylesheets/decidim/editor.scss"

window.DecidimKit = DecidimKit;
window.currentEditors = window.currentEditors || [];

window.createEditor = (container) => {
  let editor = createEditor(container);
  window.currentEditors.push(editor);
  return editor;
}
