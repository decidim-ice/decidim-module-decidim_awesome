// = require codemirror
// = require mode/css/css
// = require keymap/sublime
// = require_self

$(() => {
  $(".awesome-edit-config .scoped_styles_container textarea").each((_idx, el) => {
    CodeMirror.fromTextArea(el, {
      lineNumbers: true,
      mode: "css",
      keymap: "sublime"
    });
  })
});
