// = require codemirror
// = require mode/css/css
// = require mode/yaml/yaml
// = require_self

$(() => {
  $(".awesome-edit-config .scoped-style textarea").each((_idx, el) => {
    console.log(el)
    var editor = CodeMirror.fromTextArea(el, {
      lineNumbers: true,
      mode: "css"
    });
  })

  $(".awesome-edit-config .proposal-custom-field textarea").each((_idx, el) => {
    console.log(el)
    var editor = CodeMirror.fromTextArea(el, {
      lineNumbers: true,
      mode: "yaml"
    });
  })
});
