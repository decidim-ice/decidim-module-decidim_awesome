// = require codemirror
// = require mode/css/css
// = require_self

$(() => {
  $(".awesome-edit-config .scoped-style textarea").each((_idx, el) => {
    console.log(el)
    var editor = CodeMirror.fromTextArea(el, {
      lineNumbers: true,
      // theme: "monokai",
      mode: "css",
      viewportMargin: 5
    });
  })
});
