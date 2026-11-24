import { EditorView } from "@codemirror/view";
import { escapeHtml } from "src/decidim/utilities/text";

const tagFor = ({ url, filename, content_type: contentType }) => {
  const name = escapeHtml(filename);

  if (contentType.startsWith("image/")) {
    return `<img src="${escapeHtml(url)}" alt="${name}">`;
  }

  return `<a href="${escapeHtml(url)}">${name}</a>`;
};

// Uploads a file and inserts the tag pointing to it at the cursor, rejects with the reason given by the server
export const uploadFile = async (view, file) => {
  const body = new FormData();
  body.append("file", file);

  const response = await fetch(window.DecidimAwesome.htmlCodeEditorFilesPath, {
    method: "POST",
    headers: {
      "Accept": "application/json",
      "X-Requested-With": "XMLHttpRequest",
      "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")?.content
    },
    body
  }).catch(() => null);
  const data = await response?.json().catch(() => null);

  if (!response?.ok || !data) {
    throw new Error(data?.message || "");
  }

  view.dispatch(view.state.replaceSelection(tagFor(data)));
};

// Sends the files dropped in the code editor to the given function, with the cursor placed where they are dropped
export const fileDrop = (onFiles) => EditorView.domEventHandlers({
  drop: (event, view) => {
    const files = Array.from(event.dataTransfer?.files || []);
    if (files.length === 0) {
      return false;
    }

    event.preventDefault();
    view.dispatch({ selection: { anchor: view.posAtCoords({ "x": event.clientX, "y": event.clientY }, false) } });
    onFiles(view, files);

    return true;
  }
});
