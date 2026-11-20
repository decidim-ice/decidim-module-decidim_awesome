import { EditorView, keymap, lineNumbers } from "@codemirror/view";
import { defaultKeymap, history, historyKeymap } from "@codemirror/commands";
import { bracketMatching, defaultHighlightStyle, indentOnInput, syntaxHighlighting } from "@codemirror/language";
import { css } from "@codemirror/lang-css";

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".awesome-edit-config .scoped_styles_container textarea").forEach((textarea) => {
    const syncTextarea = EditorView.updateListener.of((update) => {
      if (update.docChanged) {
        textarea.value = update.state.doc.toString();
      }
    });
    const view = new EditorView({
      doc: textarea.value,
      extensions: [
        lineNumbers(),
        history(),
        indentOnInput(),
        bracketMatching(),
        syntaxHighlighting(defaultHighlightStyle, { fallback: true }),
        keymap.of([...defaultKeymap, ...historyKeymap]),
        css(),
        syncTextarea
      ]
    });

    textarea.after(view.dom);
    textarea.style.display = "none";
  });
});
