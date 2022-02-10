import CodeMirror from "codemirror"
import "codemirror/mode/css/css"
import "codemirror/keymap/sublime"
import "stylesheets/decidim/decidim_awesome/admin/codemirror.scss";

$(() => {
  $(".awesome-edit-config .scoped_styles_container textarea").each((_idx, el) => {
    CodeMirror.fromTextArea(el, {
      lineNumbers: true,
      mode: "css",
      keymap: "sublime"
    });
  })
});
