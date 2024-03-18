import FormStorage from "form-storage";

document.addEventListener("DOMContentLoaded", () => {
  window.DecidimAwesome = window.DecidimAwesome || {};
  if (!window.DecidimAwesome.auto_save_forms) {
    return;
  }

  const questionnaireId = window.DecidimAwesome.current_questionnaire;
  if (!questionnaireId) {
    // console.log("Not a questionnaire page")
    return;
  }

  const storeId = `awesome_autosave:${questionnaireId}`;
  const storeCheckboxesId = `awesome_autosave:checkboxes:${questionnaireId}`;
  const form = document.querySelector("form.answer-questionnaire");

  if (!form) {
    if (window.DecidimAwesome.questionnaire_answered) {
      // console.log("Questionnaire already answered, remove any data saved");
      window.localStorage.removeItem(storeId);
      window.localStorage.removeItem(storeCheckboxesId);
    }
    // console.log("No forms here");
    return;
  }

  const store = new FormStorage(`#${form.id}`, {
    name: storeId,
    ignores: [
      // '[type="hidden"]',
      '[name="utf8"]',
      '[name="authenticity_token"]',
      "[disabled]",
      // there are problems with matrix questions
      '[type="checkbox"]'
    ]
  });

  const showMsg = (msg, error = false, defaultTime = 700) => {
    const time = error
      ? 5000
      : defaultTime;
    const div = document.createElement("div");
    div.className = `awesome_autosave-notice${error
      ? " error"
      : ""}`;
    div.textContent = msg;
    form.appendChild(div);
    setTimeout(() => {
      div.remove();
    }, time);
  };

  if (!window.localStorage) {
    showMsg(window.DecidimAwesome.texts.autosaved_error, true);
    return;
  }

  if (window.localStorage.getItem(storeId)) {
    showMsg(window.DecidimAwesome.texts.autosaved_retrieved, false, 5000);
  }

  // restore if available
  Reflect.apply(store.apply, store, []);
  // restore checkboxes
  try {
    let checkboxes = JSON.parse(window.localStorage.getItem(storeCheckboxesId));
    Object.keys(checkboxes).forEach((id) => {
      Reflect.apply(
        document.getElementById,
        document,
        [id]
      ).checked = checkboxes[id];
    });
  } catch (evt) {
    console.log("No checkboxes found");
  }

  const save = () => {
    store.save();
    // save checkbox manually
    let checkboxes = {};
    form.querySelectorAll('input[type="checkbox"]').forEach((el) => {
      checkboxes[el.id] = el.checked;
    });
    window.localStorage.setItem(storeCheckboxesId, JSON.stringify(checkboxes));
    showMsg(window.DecidimAwesome.texts.autosaved_success);
  };

  // save changes when modifications
  form.addEventListener("change", save);
});
