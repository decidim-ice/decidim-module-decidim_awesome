import {awesomeCreateQuillEditor} from "src/decidim/decidim_awesome/editors/editor"

console.log("APP OVERRIDE EDITOR")
export default function createQuillEditor(container) {
  return awesomeCreateQuillEditor(container);
}