import { css } from "@codemirror/lang-css";

import createCodeEditor from "src/decidim/decidim_awesome/code_editor";

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".awesome-edit-config .scoped_styles_container textarea").forEach((textarea) => {
    const view = createCodeEditor(textarea, [css()]);

    textarea.after(view.dom);
    textarea.style.display = "none";
  });
});
