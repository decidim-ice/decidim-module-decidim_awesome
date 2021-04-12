// = require codemirror
// = require mode/css/css
// = require mode/yaml/yaml
// = require keymap/sublime
// = require_self

$(() => {
  $(".awesome-edit-config .scoped-style textarea").each((_idx, el) => {
    CodeMirror.fromTextArea(el, {
      lineNumbers: true,
      mode: "css",
      keymap: "sublime"
    });
  })
});
