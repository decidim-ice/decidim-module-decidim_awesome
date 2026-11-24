import { EditorView, keymap } from "@codemirror/view";
import { html } from "@codemirror/lang-html";
import { syntaxTree } from "@codemirror/language";
import { lintKeymap, linter } from "@codemirror/lint";

import { uniqueId } from "src/decidim/editor/common/helpers";
import createCodeEditor from "src/decidim/decidim_awesome/code_editor";
import openPreview from "src/decidim/decidim_awesome/admin/html_code_editor_preview";
import { fileDrop, uploadFile } from "src/decidim/decidim_awesome/admin/html_code_editor_upload";

const { htmlCodeEditorAllowedTags: allowedTags = [], htmlCodeEditorAllowedMime: allowedMime = [], i18n: messages = {} } = window.DecidimAwesome || {};

// Warns about the tags that are removed when the content is displayed
const notAllowedTags = (view) => {
  const diagnostics = [];

  syntaxTree(view.state).iterate({
    enter: (node) => {
      // The closing tags and the CSS selectors inside a style tag are tag names as well
      if (node.name !== "TagName" || !["OpenTag", "SelfClosingTag"].includes(node.node.parent.name)) {
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

const createButton = (label, onClick) => {
  const button = document.createElement("button");

  button.type = "button";
  button.className = "button button__sm button__transparent-secondary";
  button.textContent = label;
  button.addEventListener("click", onClick);

  return button;
};

/**
 * Creates an HTML code editor that takes the place of the rich text editor and updates the same hidden input.
 *
 * @param {HTMLElement} editorContainer The element where the editor is rendered.
 * @param {HTMLElement} input The hidden input submitted with the form.
 * @return {EditorView} The code editor instance.
 */
export default function createHtmlCodeEditor(editorContainer, input) {
  const canUpload = allowedMime.length > 0 && !input.disabled;
  const label = input.parentElement.querySelector("label");
  const toolbar = document.createElement("div");
  const message = document.createElement("span");

  // Files are stored one after the other so every tag lands where the previous one ends
  const upload = async (view, files) => {
    message.textContent = "";

    for (const file of files) {
      try {
        await uploadFile(view, file);
      } catch (error) {
        message.textContent = [messages.htmlCodeEditorUploadError, error.message].filter(Boolean).join(": ");
      }
    }
  };

  const extensions = [html(), EditorView.lineWrapping, linter(notAllowedTags), keymap.of(lintKeymap)];
  if (label) {
    label.id = label.id || uniqueId("editorlabel");
    extensions.push(EditorView.contentAttributes.of({ "aria-labelledby": label.id }));
  }
  if (canUpload) {
    extensions.push(fileDrop(upload));
  }
  const view = createCodeEditor(input, extensions);

  toolbar.className = "editor-toolbar awesome-code-editor-toolbar";
  toolbar.append(createButton(messages.htmlCodeEditorPreview, (event) => {
    message.textContent = "";
    openPreview(view.state.doc.toString(), event.currentTarget).catch(() => {
      message.textContent = messages.htmlCodeEditorPreviewError;
    });
  }));

  if (canUpload) {
    const fileInput = document.createElement("input");

    fileInput.type = "file";
    fileInput.accept = allowedMime.join(",");
    fileInput.multiple = true;
    fileInput.hidden = true;
    fileInput.addEventListener("change", () => {
      upload(view, Array.from(fileInput.files));
      fileInput.value = "";
    });
    toolbar.append(createButton(messages.htmlCodeEditorUpload, () => fileInput.click()), fileInput);
  }

  message.className = "awesome-code-editor-toolbar__message";
  message.setAttribute("role", "status");
  toolbar.append(message);

  editorContainer.before(toolbar);
  editorContainer.append(view.dom);

  return view;
}
