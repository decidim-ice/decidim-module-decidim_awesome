import { Controller } from "@hotwired/stimulus";

// The rich text editor is loaded on demand, so it is not added to every admin page
const createRichTextEditor = (element) => {
  return import("src/decidim/decidim_awesome/editor").then(({ default: createEditor }) => createEditor(element));
};

// Takes the place of the Decidim editor controller to render the HTML code editor in the admin editors
export default class extends Controller {
  connect() {
    if (this.element.dataset.editorInitialized) {
      return;
    }

    const { context } = JSON.parse(this.element.dataset.options);
    let editor = null;

    // Decidim fills the answer of a proposal from its templates through the rich text editor
    if (context === "admin" && !document.getElementById("proposal_answer_template_chooser")) {
      const input = this.element.parentElement.querySelector("input[type=hidden]");
      const editorContainer = this.element.querySelector(".editor-input");

      // The rich text editor is kept when the code editor cannot be loaded or created
      editor = import("src/decidim/decidim_awesome/admin/html_code_editor").
        then(({ default: createHtmlCodeEditor }) => createHtmlCodeEditor(editorContainer, input)).
        catch(() => createRichTextEditor(this.element));
    } else {
      editor = createRichTextEditor(this.element);
    }

    editor.then((instance) => {
      this.editor = instance;
    });
    this.element.dataset.editorInitialized = true;
  }
}
