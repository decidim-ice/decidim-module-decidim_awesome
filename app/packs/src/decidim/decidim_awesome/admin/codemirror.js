import CodeMirror from "codemirror"
import "codemirror/mode/css/css"
import "codemirror/keymap/sublime"
import "codemirror/lib/codemirror.css";

$(() => {
  $(".awesome-edit-config .scoped_styles_container textarea").each((_idx, el) => {
    CodeMirror.fromTextArea(el, {
      lineNumbers: true,
      mode: "css",
      keymap: "sublime"
    });
  })
});
