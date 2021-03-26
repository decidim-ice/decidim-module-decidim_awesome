// = require codemirror
// = require mode/css/css
// = require mode/yaml/yaml
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

  $(".awesome-edit-config .proposal-custom-field textarea").each((_idx, el) => {
    console.log(el)
    var editor = CodeMirror.fromTextArea(el, {
      lineNumbers: true,
      mode: "yaml",
      keymap: "sublime"
    });
  })
});
