// = require codemirror
// = require mode/css/css
// = require keymap/sublime
// = require_self

$(() => {
  $(".awesome-edit-config .scoped-style textarea").each((_idx, el) => {
    console.log(el)
    var editor = CodeMirror.fromTextArea(el, {
      lineNumbers: true,
      mode: "css",
      keymap: "sublime"
    });
  })
});
