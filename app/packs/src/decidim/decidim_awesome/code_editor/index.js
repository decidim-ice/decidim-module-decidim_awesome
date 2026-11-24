import { EditorState } from "@codemirror/state";
import { EditorView, keymap, lineNumbers } from "@codemirror/view";
import { defaultKeymap, history, historyKeymap, indentWithTab } from "@codemirror/commands";
import { bracketMatching, defaultHighlightStyle, indentOnInput, syntaxHighlighting } from "@codemirror/language";

/**
 * Creates a code editor that keeps a form field updated with its content.
 *
 * @param {HTMLElement} field The textarea or input that is submitted with the form.
 * @param {Array} extensions Extra CodeMirror extensions, such as the language.
 * @return {EditorView} The code editor, not attached to the document yet.
 */
export default function createCodeEditor(field, extensions = []) {
  const syncField = EditorView.updateListener.of((update) => {
    if (update.docChanged) {
      field.value = update.state.doc.toString();
    }
  });

  return new EditorView({
    doc: field.value,
    extensions: [
      lineNumbers(),
      history(),
      indentOnInput(),
      bracketMatching(),
      syntaxHighlighting(defaultHighlightStyle, { fallback: true }),
      keymap.of([...defaultKeymap, ...historyKeymap, indentWithTab]),
      EditorView.editable.of(!field.disabled),
      EditorState.readOnly.of(field.disabled),
      syncField,
      ...extensions
    ]
  });
}
