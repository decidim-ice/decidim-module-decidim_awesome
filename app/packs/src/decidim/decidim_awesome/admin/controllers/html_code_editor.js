import { Controller } from "@hotwired/stimulus";
import createEditor from "src/decidim/editor";

// Takes the place of the Decidim editor controller to render the HTML code editor in the admin editors
export default class extends Controller {
  connect() {
    if (this.element.dataset.editorInitialized) {
      return;
    }

    const { context } = JSON.parse(this.element.dataset.options);
    if (context === "admin") {
      const input = this.element.parentElement.querySelector("input[type=hidden]");
      const editorContainer = this.element.querySelector(".editor-input");

      import("src/decidim/decidim_awesome/admin/html_code_editor").then(({ default: createHtmlCodeEditor }) => {
        this.editor = createHtmlCodeEditor(editorContainer, input);
      });
    } else {
      this.editor = createEditor(this.element);
    }

    this.element.dataset.editorInitialized = true;
  }
}
