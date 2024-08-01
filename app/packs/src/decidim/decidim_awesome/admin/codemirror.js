import CodeMirror from "codemirror"
import "codemirror/mode/css/css"
import "codemirror/keymap/sublime"
import "codemirror/lib/codemirror.css";

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".awesome-edit-config .scoped_styles_container textarea").forEach((el) => {
    CodeMirror.fromTextArea(el, {
      lineNumbers: true,
      mode: "css",
      keymap: "sublime"
    });
  })
});
