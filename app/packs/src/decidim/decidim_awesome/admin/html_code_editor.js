import { EditorView } from "@codemirror/view";
import { html } from "@codemirror/lang-html";
import { syntaxTree } from "@codemirror/language";
import { linter } from "@codemirror/lint";

import createCodeEditor from "src/decidim/decidim_awesome/code_editor";

// Warns about the tags that are removed when the content is displayed
const notAllowedTags = (view) => {
  const { htmlCodeEditorAllowedTags: allowedTags = [], i18n: messages = {} } = window.DecidimAwesome || {};
  const diagnostics = [];

  syntaxTree(view.state).iterate({
    enter: (node) => {
      if (node.name !== "TagName" || node.node.parent.name === "CloseTag") {
        return;
      }

      const tag = view.state.sliceDoc(node.from, node.to).toLowerCase();
      if (!allowedTags.includes(tag)) {
        diagnostics.push({ from: node.from, to: node.to, severity: "warning", message: messages.htmlCodeEditorTagNotAllowed });
      }
    }
  });

  return diagnostics;
};

/**
 * Creates an HTML code editor that takes the place of the rich text editor and updates the same hidden input.
 *
 * @param {HTMLElement} editorContainer The element where the editor is rendered.
 * @param {HTMLElement} input The hidden input submitted with the form.
 * @return {EditorView} The code editor instance.
 */
export default function createHtmlCodeEditor(editorContainer, input) {
  const view = createCodeEditor(input, [html(), EditorView.lineWrapping, linter(notAllowedTags)]);

  editorContainer.append(view.dom);

  return view;
}
