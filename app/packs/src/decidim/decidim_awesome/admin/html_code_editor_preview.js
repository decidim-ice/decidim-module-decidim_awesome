const DIALOG = "awesome-html-code-preview";

// Only the answer to the last preview requested is shown
let lastRequest = 0;

// The dialog is rendered in the admin layout inside a template
const createDialog = () => {
  const dialog = document.getElementById(`${DIALOG}-template`).content.firstElementChild.cloneNode(true);

  document.body.append(dialog);
  window.createDialog(dialog);

  return dialog;
};

/**
 * Shows the HTML as the visitors see it, once the server has removed what is not allowed.
 *
 * @param {String} content The HTML written in the code editor.
 * @param {HTMLElement} trigger The element that gets the focus back when the preview is closed.
 * @return {Promise} Rejected when the preview cannot be rendered.
 */
export default async function openPreview(content, trigger) {
  const request = (lastRequest += 1);
  const response = await fetch(window.DecidimAwesome.htmlCodeEditorPreviewsPath, {
    method: "POST",
    headers: {
      "X-Requested-With": "XMLHttpRequest",
      "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")?.content
    },
    body: new URLSearchParams({ content })
  });

  if (!response.ok) {
    throw new Error(response.statusText);
  }

  const html = await response.text();
  if (request !== lastRequest) {
    return;
  }

  const dialog = document.getElementById(DIALOG) || createDialog();

  dialog.querySelector("iframe").srcdoc = html;
  dialog.addEventListener("close.dialog", () => trigger.focus(), { once: true });
  window.Decidim.currentDialogs[DIALOG].open();
}
