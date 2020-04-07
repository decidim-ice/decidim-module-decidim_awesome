// = require highlight.min.js
// = require_self

window.DecidimAwesome = window.DecidimAwesome || {};

if(window.DecidimAwesome.use_markdown_in_proposals) {
  document.addEventListener('DOMContentLoaded', (event) => {
    document.querySelectorAll('.awesome-markdown-editor pre code').forEach((block) => {
      hljs.highlightBlock(block);
    });
  });
}
