// TODO
// = require mode/css/css
// = require keymap/sublime
// TODO

import "codemirror"

$(() => {
  $(".awesome-edit-config .scoped_styles_container textarea").each((_idx, el) => {
    CodeMirror.fromTextArea(el, {
      lineNumbers: true,
      mode: "css",
      keymap: "sublime"
    });
  })
});
